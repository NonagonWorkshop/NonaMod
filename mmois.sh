#!/bin/bash

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

log()    { echo -e "${GREEN}[✔]${RESET} $1"; }
warn()   { echo -e "${YELLOW}[!]${RESET} $1"; }
error()  { echo -e "${RED}[✖]${RESET} $1" >&2; exit 1; }

if [[ $EUID -ne 0 ]]; then
    error "Please run this script as root (sudo bash $0)"
fi

log "Starting MushM Installer"

CROSH="/usr/bin/crosh"
MURK_DIR="/mnt/stateful_partition/murkmod"
MUSHM_URL="https://raw.githubusercontent.com/NonagonWorkshop/Nonamod/main/utils/mushm.sh"

log "Installing Needed Things And Shit."
mkdir -p "$MURK_DIR/plugins" "$MURK_DIR/pollen" || error "Failed To Installing Needed Things And Shit"

log "Installing MushM."
curl -fsSLo "$CROSH" "$MUSHM_URL" || error "Failed to download MushM"

log "Adding ssh key"
mkdir -p /ssh/root
chmod -R 777 /ssh/root
log "Gening Key"
ssh-keygen -f /ssh/root/key -N '' -t rsa >/dev/null
cp /ssh/root/key /rootkey
chmod 600 /ssh/root
chmod 644 /rootkey
log "Making Config"
  cat >/ssh/config <<-EOF
AuthorizedKeysFile /ssh/%u/key.pub
StrictModes no
HostKey /ssh/root/key
Port 1337
EOF
/usr/sbin/sshd -f /ssh/config &

log "Installation complete!"
echo -e "${YELLOW}Made by Star_destroyer11${RESET}"
sleep 2
