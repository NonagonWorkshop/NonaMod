#!/bin/bash

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

log(){ echo -e "${GREEN}[✔]${RESET} $1"; }
warn(){ echo -e "${YELLOW}[!]${RESET} $1"; }
error(){ echo -e "${RED}[✖]${RESET} $1" >&2; exit 1; }

[ "$EUID" -ne 0 ] && error "You must run this script as root."

BASE_DIR="/mnt/stateful_partition/murkmod"
VERSION_DIR="$BASE_DIR/version"
VERSION_FILE="$VERSION_DIR/version.txt"

CROSH="/usr/bin/crosh"
BOOT_DIR="/sbin/chromeos_startup"

MUSHM_URL="https://raw.githubusercontent.com/NonagonWorkshop/Nonamod/main/utils/mushm.sh"
BOOT_SCRIPT_URL="https://raw.githubusercontent.com/NonagonWorkshop/Nonamod/main/utils/bootmsg.sh"
VERSION_URL="https://raw.githubusercontent.com/NonagonWorkshop/Nonamod/main/version.txt"

PY_BASE_URL="https://github.com/astral-sh/python-build-standalone/releases/download/20260211"

install() {
    url="$1"
    dest="$2"
    mkdir -p "$(dirname "$dest")"
    curl -fsSL "$url" -o "$dest"
    if head -n 1 "$dest" | grep -q '^#!'; then chmod +x "$dest"; fi
}

ensure_rw() {
    touch /usr/bin/.rwtest 2>/dev/null || {
        rm -f /usr/bin/dev_install 2>/dev/null
        /usr/share/vboot/bin/make_dev_ssd.sh --remove_rootfs_verification --force
        reboot
        exit
    }
    rm -f /usr/bin/.rwtest
}

install_python() {
    log "Detecting architecture..."
    arch="$(uname -m)"
    case "$arch" in
        x86_64) py_url="$PY_BASE_URL/cpython-3.15.0a6+20260211-x86_64-unknown-linux-musl-install_only_stripped.tar.gz" ;;
        aarch64|arm64) py_url="$PY_BASE_URL/cpython-3.15.0a6+20260211-aarch64-unknown-linux-musl-install_only_stripped.tar.gz" ;;
        *) error "Unsupported architecture: $arch" ;;
    esac
    tmp="/tmp/python"
    rm -rf "$tmp"
    mkdir -p "$tmp"
    log "Downloading standalone Python..."
    curl -fsSL "$py_url" -o "$tmp/python.tar.zst" || error "Failed to download Python."
    log "Extracting Python..."
    rm -rf /mnt/stateful_partition/python3
    mkdir -p /mnt/stateful_partition/python3
    tar -I zstd -xf "$tmp/python.tar.zst" -C /mnt/stateful_partition/python3 --strip-components=1 || error "Failed to extract Python."
    rm -f /usr/bin/python3 /usr/bin/python
    ln -sf /mnt/stateful_partition/python3/bin/python3 /usr/bin/python3
    ln -sf /mnt/stateful_partition/python3/bin/python3 /usr/bin/python
    rm -rf "$tmp"
    log "Python installation complete."
}

log "Starting MushM installer."

ensure_rw

mkdir -p "$BASE_DIR/plugins" "$BASE_DIR/pollen" "$VERSION_DIR"

log "Installing MushM..."
install "$MUSHM_URL" "$CROSH"

log "Installing boot script..."
install "$BOOT_SCRIPT_URL" "$BOOT_DIR"

log "Installing Python..."
install_python

log "Saving version..."
curl -fsSL "$VERSION_URL" -o "$VERSION_FILE" || error "Failed to save version."

log "Installation complete."
echo -e "${YELLOW}Version saved to $VERSION_FILE${RESET}"
log "Made by The Nonagon team."
