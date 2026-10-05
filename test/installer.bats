#!/usr/bin/env bats
# test/installer.bats — Test suite for raspbian-installer

setup() {
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
    RUNNER="${SCRIPT_DIR}/installer.sh"
}

# ── Syntax ───────────────────────────────────────────────────────────────────

@test "installer.sh has valid bash syntax" {
    run bash -n "$RUNNER"
    [ "$status" -eq 0 ]
}

@test "installer.sh uses strict mode" {
    grep -q 'set -euo pipefail' "$RUNNER"
}

@test "installer.sh is executable" {
    [ -x "$RUNNER" ]
}

# ── Config ───────────────────────────────────────────────────────────────────

@test "installer.config exists and is readable" {
    [ -f "${SCRIPT_DIR}/installer.config" ]
    [ -r "${SCRIPT_DIR}/installer.config" ]
}

@test "installer.config defines required variables" {
    source "${SCRIPT_DIR}/installer.config"
    [ -n "$depends" ]
    [ -n "$jessieurl" ]
    [ -n "$stretchurl" ]
    [ -n "$INSTLL" ]
}

@test "jessieurl points to a valid URL" {
    source "${SCRIPT_DIR}/installer.config"
    [[ "$jessieurl" =~ ^https?:// ]]
}

@test "stretchurl points to a valid URL" {
    source "${SCRIPT_DIR}/installer.config"
    [[ "$stretchurl" =~ ^https?:// ]]
}

# ── Help / Usage ─────────────────────────────────────────────────────────────

@test "shows usage on unknown command" {
    run bash "$RUNNER" invalidcommand 2>&1
    [ "$status" -ne 0 ]
    grep -qi "usage" <<< "$output"
}

# ── Dependency check ─────────────────────────────────────────────────────────

@test "check_deps function exists" {
    grep -q 'check_deps()' "$RUNNER"
}

@test "check_deps detects missing commands" {
    source "${SCRIPT_DIR}/installer.config"
    # Verify the function references the expected deps
    grep -q 'wget' "$RUNNER"
    grep -q 'unzip' "$RUNNER"
    grep -q 'whiptail' "$RUNNER"
    grep -q 'pv' "$RUNNER"
    grep -q 'git' "$RUNNER"
}

# ── Safety ───────────────────────────────────────────────────────────────────

@test "burn function requires confirmation" {
    grep -q 'confirm' "$RUNNER"
}

@test "backup function requires root" {
    grep -q 'require_root' "$RUNNER"
}

@test "restore function requires root" {
    grep -q 'require_root' "$RUNNER"
}

@test "burn uses pv for progress" {
    grep -q 'pv' "$RUNNER"
}

@test "burn uses dd with fsync" {
    grep -q 'conv=fsync' "$RUNNER"
}

# ── Functions exist ──────────────────────────────────────────────────────────

@test "all expected functions are defined" {
    for func in log warn die require_cmd require_root confirm check_deps \
                burn burn_jessie burn_stretch backup restore modify show_menu main; do
        grep -q "${func}()" "$RUNNER"
    done
}

# ── No known bugs from original ──────────────────────────────────────────────

@test "no spaces around = in variable assignment" {
    # The original had: choice = $(...) which is invalid
    ! grep -E '^\s*\w+\s+=\s' "$RUNNER"
}

@test "no references to deprecated git.io shortener" {
    ! grep -q 'git.io' "$RUNNER"
}

@test "no references to EOL Node.js 8.x" {
    ! grep -q 'setup_8.x' "$RUNNER"
}

@test "no references to non-existent modipy package" {
    ! grep -q 'modipy' "$RUNNER"
}

# ── CI ───────────────────────────────────────────────────────────────────────

@test "CI workflow exists" {
    [ -f "${SCRIPT_DIR}/.github/workflows/ci.yml" ]
}

@test "CI workflow references ci-templates" {
    grep -q 'ci-templates' "${SCRIPT_DIR}/.github/workflows/ci.yml"
}
