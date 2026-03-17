#!/bin/bash

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

log()   { echo -e "${GREEN}[✔]${RESET} $1"; }
warn()  { echo -e "${YELLOW}[!]${RESET} $1"; }
error() { echo -e "${RED}[✖]${RESET} $1"; exit 1; }

[ "$EUID" -ne 0 ] && error "Run as root"

install() {
    url="$1"
    dest="$2"

    mkdir -p "$(dirname "$dest")"
    tmp="/tmp/$(basename "$dest").tmp"

    curl -fsSL "$url" -o "$tmp" || error "Failed to download $url"

    # If dest doesn't exist OR files differ, update
    if [ ! -f "$dest" ] || ! diff "$tmp" "$dest" >/dev/null 2>&1; then
        mv "$tmp" "$dest"
        head -n 1 "$dest" | grep -q '^#!' && chmod +x "$dest"
        log "Updated $(basename "$dest")"
    else
        rm "$tmp"
        log "$(basename "$dest") already up to date"
    fi
}


ensure_rw() {
    touch /usr/bin/.rwtest 2>/dev/null || {
        rm -f /usr/bin/dev_install
        /usr/share/vboot/bin/make_dev_ssd.sh --remove_rootfs_verification --force
        
    }
    rm -f /usr/bin/.rwtest
}

install_python() {
    if command -v python3 >/dev/null; then
        log "Python already installed"
        return
    fi

    log "Installing Python"
    arch="$(uname -m)"
    case "$arch" in
        x86_64) PY_URL="$PY_BASE/cpython-3.15.0a6+20260211-x86_64-unknown-linux-musl-install_only_stripped.tar.gz" ;;
        aarch64|arm64) PY_URL="$PY_BASE/cpython-3.15.0a6+20260211-aarch64-unknown-linux-musl-install_only_stripped.tar.gz" ;;
        *) error "Unsupported architecture: $arch" ;;
    esac

    tmp="/tmp/python"
    rm -rf "$tmp"
    mkdir -p "$tmp"

    curl -fsSL "$PY_URL" -o "$tmp/python.tar.zst" || error "Python download failed"
    rm -rf /mnt/stateful_partition/python3
    mkdir -p /mnt/stateful_partition/python3
    tar -I zstd -xf "$tmp/python.tar.zst" -C /mnt/stateful_partition/python3 --strip-components=1 || error "Python extract failed"

    ln -sf /mnt/stateful_partition/python3/bin/python3 /usr/bin/python3
    ln -sf /mnt/stateful_partition/python3/bin/python3 /usr/bin/python

    rm -rf "$tmp"
    log "Python installed"
}

log "Starting MushM Installer"

BASE="/mnt/stateful_partition/murkmod"
VERDIR="$BASE/version"
VERFILE="$VERDIR/version.txt"
CROSH="/usr/bin/crosh"
BOOT="/sbin/chromeos_startup"
MUSHM_URL="https://raw.githubusercontent.com/NonagonWorkshop/Nonamod/main/utils/mushm.sh"
BOOTMSG_URL="https://raw.githubusercontent.com/NonagonWorkshop/Nonamod/main/utils/bootmsg.sh"
VERSION_URL="https://raw.githubusercontent.com/NonagonWorkshop/Nonamod/main/version.txt"
BACKUP_URL="https://raw.githubusercontent.com/NonagonWorkshop/NonaMod/main/utils/backupthings/backup_manager.py"
PY_BASE="https://github.com/astral-sh/python-build-standalone/releases/download/20260211"

ensure_rw

log "Creating directories"
mkdir -p "$BASE/plugins" "$BASE/pollen" "$VERDIR" "$BASE/python/util/backup" /ssh/root

log "Installing MushM"
install "$MUSHM_URL" "$CROSH"

log "Installing boot script"
install "$BOOTMSG_URL" "$BOOT"

log "Installing Python"
install_python

log "Saving version"
curl -fsSL "$VERSION_URL" -o "$VERFILE" || error "Failed to save version"

log "Installing backup manager"
install "$BACKUP_URL" "$BASE/python/util/backup/backup_manager.py"

chmod 700 /ssh/root

KEY1="/ssh/root/key"
KEY2="/ssh/root/key2"

log "Checking SSH keys"

if [ ! -f "$KEY1" ]; then
    log "Generating key 1"
    ssh-keygen -t rsa -f "$KEY1" -N '' >/dev/null 2>&1 || error "Key 1 generation failed"
else
    log "Key 1 exists"
fi

if [ ! -f "$KEY2" ]; then
    log "Generating key 2"
    ssh-keygen -t rsa -f "$KEY2" -N '' >/dev/null 2>&1 || error "Key 2 generation failed"
else
    log "Key 2 exists"
fi

chmod 600 "$KEY1" "$KEY2"
chmod 644 "$KEY1.pub" "$KEY2.pub"

log "Copying keys to /rootkey and /rootkey2"
cp "$KEY1" /rootkey
cp "$KEY2" /rootkey2
chown chronos:chronos /rootkey /rootkey2
chmod 600 /rootkey /rootkey2

log "Creating SSH config"
cat >/ssh/config <<EOF
AuthorizedKeysFile /ssh/%u/key.pub /ssh/%u/key2.pub
StrictModes no
HostKey /ssh/root/key
HostKey /ssh/root/key2
Port 1337
EOF

chmod 600 /ssh/config

log "Starting SSH daemon"
/usr/sbin/sshd -f /ssh/config || error "Failed to start SSH daemon"

log "Installation complete!"
echo -e "${YELLOW}Made by Star_destroyer11${RESET}"
(sleep 5; reboot) &
