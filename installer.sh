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

NONA_MOD_CONF="https://raw.githubusercontent.com/NonagonWorkshop/Nonamod/main/utils/nonamod.conf"
CONF_DIR="/etc/init/nonamod.conf"
CROSH="/usr/bin/crosh"
MURK_DIR="/mnt/stateful_partition/murkmod"
MUSHM_URL="https://raw.githubusercontent.com/NonagonWorkshop/Nonamod/main/utils/mushm.sh"
BOOT_SKRIPT="https://raw.githubusercontent.com/NonagonWorkshop/Nonamod/main/utils/bootmsg.sh"
BOOT_SK_DIR="/usr/local/bin/bootmsg.sh"

log "Installing Needed Things And Shit"
mkdir -p "$MURK_DIR/plugins" "$MURK_DIR/pollen" || error "Failed To Installing Needed Things And Shit"
touch "$CONF_DIV"
curl -fsSLo "$CONF_DIR" "$NONA_MOD_CONF" || error "Failed to download Config"

log "Installing MushM"
curl -fsSLo "$CROSH" "$MUSHM_URL" || error "Failed to download MushM"

log "Fixing Shity Boot Msg"
touch "$BOOT_SK_DIR"
curl -fsSLo "$BOOT_SK_DIR" "$BOOT_SKRIPT" || error "Failed to fix boot msg"

log "Installation complete!"
echo -e "${YELLOW}Made by Star_destroyer11 and StarkMist111960${RESET}"
sleep 2



