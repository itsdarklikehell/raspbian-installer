#!/bin/bash
#
# raspbian-installer — Download, burn, backup, restore, and modify Raspbian.
#
# Usage:
#   ./installer.sh [command]
#
# Commands:
#   burn      Download a Raspbian image and burn it to a device
#   backup    Create a backup image of a drive/partition
#   restore   Restore a drive/partition from a backup image
#   modify    Install tools and modify the current running system
#   menu      Interactive menu (default)
#
set -euo pipefail

# ── Configuration ────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/installer.config"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "ERROR: Config file not found: $CONFIG_FILE" >&2
    exit 1
fi

# shellcheck source=/dev/null
source "$CONFIG_FILE"

# ── Helpers ──────────────────────────────────────────────────────────────────

log()  { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[WARN]\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m[ERROR]\033[0m %s\n' "$*" >&2; exit 1; }

require_cmd() {
    command -v "$1" &>/dev/null || die "Required command not found: $1"
}

require_root() {
    [[ $EUID -eq 0 ]] || die "This command must be run as root (use sudo)."
}

confirm() {
    local prompt="${1:-Are you sure?}"
    local reply
    read -r -p "$prompt [y/N] " reply
    [[ "$reply" =~ ^[Yy]$ ]]
}

# ── Dependency check ────────────────────────────────────────────────────────

check_deps() {
    local deps=(wget unzip whiptail pv git curl)
    local missing=()
    for dep in "${deps[@]}"; do
        command -v "$dep" &>/dev/null || missing+=("$dep")
    done
    if (( ${#missing[@]} > 0 )); then
        warn "Missing dependencies: ${missing[*]}"
        if confirm "Install them now?"; then
            sudo apt-get update -qq
            sudo apt-get install -y "${missing[@]}"
        else
            die "Cannot continue without required dependencies."
        fi
    fi
}

# ── Burn ─────────────────────────────────────────────────────────────────────

burn() {
    local dest="$1" img_url="$2" img_file="$3"

    log "Downloading Raspbian from $img_url"
    mkdir -p "$dest"
    wget -c --show-progress "$img_url" -O "$dest/$dest.zip"

    log "Unzipping $dest/$dest.zip"
    unzip -o "$dest/$dest.zip" -d "$dest"

    local img_path="$dest/$img_file"
    [[ -f "$img_path" ]] || die "Image file not found after unzip: $img_path"

    log "Available devices:"
    lsblk -d -o NAME,SIZE,MODEL,TRAN | grep -E '^(NAME|sd|mmc)'

    local device
    read -r -p "Destination device (e.g. /dev/sdX): " device

    [[ -b "$device" ]] || die "Not a block device: $device"

    warn "ALL DATA ON $device WILL BE DESTROYED!"
    if ! confirm "Burn $img_path to $device?"; then
        echo "Aborted."
        return 1
    fi

    log "Burning $img_path to $device ..."
    sudo pv "$img_path" | sudo dd of="$device" bs=4M conv=fsync status=none
    sync

    log "Done burning to $device."
}

burn_jessie() {
    burn "Jessie" "$jessieurl" "2017-07-05-raspbian-jessie.img"
}

burn_stretch() {
    burn "Stretch" "$stretchurl" "2017-11-29-raspbian-stretch.img"
}

# ── Backup ───────────────────────────────────────────────────────────────────

backup() {
    require_root

    log "Available devices:"
    lsblk -d -o NAME,SIZE,MODEL,TRAN | grep -E '^(NAME|sd|mmc)'

    local inputfile
    read -r -p "Drive or partition to back up (without /dev/, e.g. sdXY): " inputfile

    [[ -b "/dev/$inputfile" ]] || die "Not a block device: /dev/$inputfile"

    mkdir -p Backups
    local outfile="Backups/Backup-$(date +%Y%m%d-%H%M%S).img"

    warn "Creating backup of /dev/$inputfile -> $outfile"
    if confirm "Continue?"; then
        sudo pv "/dev/$inputfile" | sudo dd of="$outfile" bs=4M conv=fsync status=none
        sync
        log "Backup saved to $outfile"
    else
        echo "Aborted."
        return 1
    fi
}

# ── Restore ──────────────────────────────────────────────────────────────────

restore() {
    require_root

    local inputfile="Backups/Backup.img"
    [[ -f "$inputfile" ]] || die "Backup file not found: $inputfile"

    log "Available devices:"
    lsblk -d -o NAME,SIZE,MODEL,TRAN | grep -E '^(NAME|sd|mmc)'

    local dest
    read -r -p "Destination device (e.g. /dev/sdX): " dest

    [[ -b "$dest" ]] || die "Not a block device: $dest"

    warn "ALL DATA ON $dest WILL BE DESTROYED!"
    if ! confirm "Restore $inputfile to $dest?"; then
        echo "Aborted."
        return 1
    fi

    log "Restoring $inputfile to $dest ..."
    sudo pv "$inputfile" | sudo dd of="$dest" bs=4M conv=fsync status=none
    sync

    log "Done restoring to $dest."
}

# ── Modify ───────────────────────────────────────────────────────────────────

modify() {
    log "Updating package lists ..."
    sudo apt-get update -qq

    log "Upgrading installed packages ..."
    sudo apt-get upgrade -y

    log "Installing useful tools ..."
    sudo apt-get install -y \
        byobu \
        wget \
        curl \
        git \
        lsb-release \
        htop \
        tree \
        ncdu \
        ripgrep \
        fd-find \
        bat \
        exa \
        zsh \
        openssh-server \
        aria2 \
        quassel-core \
        quassel-client

    log "Modify complete."
}

# ── Menu ─────────────────────────────────────────────────────────────────────

show_menu() {
    local choice
    choice=$(whiptail --title "raspbian-installer" --menu "Choose an option" 20 70 10 \
        "BURN"     "Download and burn a Raspbian image." \
        "BACKUP"   "Create a backup of a drive or partition." \
        "RESTORE"  "Restore a drive or partition from a backup." \
        "MODIFY"   "Install tools and modify the current system." \
        3>&1 1>&2 2>&3)

    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        echo "Aborted."
        return 1
    fi

    case "$choice" in
        BURN)
            local version
            version=$(whiptail --title "Select Raspbian version" --menu "Choose:" 15 60 4 \
                "JESSIE"  "Raspbian Jessie (2017-07-05)" \
                "STRETCH" "Raspbian Stretch (2017-11-29)" \
                3>&1 1>&2 2>&3)
            if [[ $? -eq 0 ]]; then
                case "$version" in
                    JESSIE)  burn_jessie ;;
                    STRETCH) burn_stretch ;;
                esac
            fi
            ;;
        BACKUP)  backup ;;
        RESTORE) restore ;;
        MODIFY)  modify ;;
    esac
}

# ── Main ─────────────────────────────────────────────────────────────────────

main() {
    check_deps

    local cmd="${1:-menu}"
    case "$cmd" in
        burn)
            burn_jessie
            ;;
        backup)
            backup
            ;;
        restore)
            restore
            ;;
        modify)
            modify
            ;;
        menu)
            show_menu
            ;;
        *)
            echo "Usage: $0 [burn|backup|restore|modify|menu]"
            exit 1
            ;;
    esac
}

main "$@"
