# raspbian-installer

Download, unzip, burn, backup, restore, and modify Raspbian images.

## Disclaimer

**Use this script with care!** Read the script before running it on a production system. I am not responsible for any damage or data loss.

## Features

1. **Burn** — Download a Raspbian image and write it to a USB/SD card
2. **Backup** — Create a backup image of a drive or partition
3. **Restore** — Restore a drive or partition from a backup image
4. **Modify** — Install useful tools on a running Raspbian system

## Usage

```bash
# Interactive menu (default)
./installer.sh

# Direct commands
./installer.sh burn      # Download and burn Raspbian Jessie
./installer.sh backup    # Create a backup image
./installer.sh restore   # Restore from backup
./installer.sh modify    # Install tools on current system
```

## Requirements

- `wget`, `unzip`, `whiptail`, `pv`, `git`, `curl`
- Root privileges for burn/backup/restore operations

## Configuration

Edit `installer.config` to change:
- Download URLs for Raspbian images
- Install command prefix
- Dependency list

## Development

### Running tests

```bash
# Install bats if not present
sudo apt-get install bats

# Run all tests
bats test/
```

### Project Structure

```
.
├── installer.sh       # Main script
├── installer.config   # Configuration
├── test/              # Bats test suite
│   └── installer.bats
├── .github/workflows/ # CI configuration
└── README.md
```

## License

MIT

---
*bauke molenaar*
