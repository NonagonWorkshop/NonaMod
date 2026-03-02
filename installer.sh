#!/bin/bash

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

log(){ echo -e "${GREEN}[✔]${RESET} $1"; }
warn(){ echo -e "${YELLOW}[!]${RESET} $1"; }
error(){ echo -e "${RED}[✖]${RESET} $1" >&2; exit 1; }

[ "$EUID" -ne 0 ] && error "You must run this script as root."

log "Starting MushM installer."

CROSH="/usr/bin/crosh"
MURK_DIR="/mnt/stateful_partition/murkmod"
MUSHM_URL="https://raw.githubusercontent.com/NonagonWorkshop/Nonamod/main/utils/mushm.sh"
BOOT_SCRIPT="https://raw.githubusercontent.com/NonagonWorkshop/Nonamod/main/utils/bootmsg.sh"
BOOT_DIR="/sbin/chromeos_startup"

mkdir -p "$MURK_DIR/plugins" "$MURK_DIR/pollen" || error "Failed to create directories."

curl -fsSLo "$CROSH" "$MUSHM_URL" || error "Failed to download MushM."
curl -fsSLo "$BOOT_DIR" "$BOOT_SCRIPT" || error "Failed to download boot script."
chmod +x "$BOOT_DIR"

# mkdir -p /mnt/stateful_partition/murkmod/py/backup && \
# curl -LO --output-dir /mnt/stateful_partition/murkmod/py/backup https://raw.githubusercontent.com/NonagonWorkshop/Nonamod/main/utils/backupthings/backup.py &&
# curl -LO --output-dir /mnt/stateful_partition/murkmod/py/backup https://raw.githubusercontent.com/NonagonWorkshop/Nonamod/main/utils/backupthings/restore.py &&
# curl -LO --output-dir /mnt/stateful_partition/murkmod/py/backup https://raw.githubusercontent.com/NonagonWorkshop/Nonamod/main/utils/backupthings/list_backups.py

ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    PY_URL="https://github.com/astral-sh/python-build-standalone/releases/download/20260211/cpython-3.15.0a6+20260211-x86_64-unknown-linux-musl-install_only_stripped.tar.gz"
elif [[ "$ARCH" == aarch64* ]] || [[ "$ARCH" == arm64* ]]; then
    PY_URL="https://github.com/astral-sh/python-build-standalone/releases/download/20260211/cpython-3.15.0a6+20260211-aarch64-unknown-linux-musl-install_only_stripped.tar.gz"
else
    error "Unsupported architecture: $ARCH"
fi

touch /usr/bin/.rwtest 2>/dev/null
if [ ! -f /usr/bin/.rwtest ]; then
    warn "Root filesystem is read-only. Making it writable."
    rm -f /usr/bin/dev_install 2>/dev/null
    /usr/share/vboot/bin/make_dev_ssd.sh --remove_rootfs_verification --force || error "Failed to make root filesystem writable."
    echo -e "${YELLOW}System will reboot. After reboot, rerun this script.${RESET}"
    sleep 5
    reboot
    exit
fi
rm -f /usr/bin/.rwtest

TMPDIR="/tmp/python"
rm -rf "$TMPDIR"
mkdir -p "$TMPDIR"

log "Downloading standalone Python."
curl -L "$PY_URL" -o "$TMPDIR/python.tar.zst" || error "Failed to download Python archive"

log "Extracting Python."
rm -rf /mnt/stateful_partition/python3
mkdir -p /mnt/stateful_partition/python3
tar -I zstd -xf "$TMPDIR/python.tar.zst" -C /mnt/stateful_partition/python3 --strip-components=1 || error "Failed to extract Python"

rm -rf /usr/bin/python3
rm -rf /usr/bin/python

ln -sf /mnt/stateful_partition/python3/bin/python3 /usr/bin/python3
ln -sf /mnt/stateful_partition/python3/bin/python3 /usr/bin/python

log "Testing Python installation."

rm -rf "$TMPDIR"

log "Installation complete."
echo -e "${YELLOW}Made by Stardestroyer12 & StarkMist111960. Py fixed by GamerRyker.${RESET}"
sleep 2
