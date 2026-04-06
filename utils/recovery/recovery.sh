#!/bin/bash

recovery_mode() {
    while true; do
        clear
        echo "MushM Recovery Mode"
        echo "(1) Reinstall MushM"
        echo "(2) Fix Permissions"
        echo "(3) Validate SSH Keys"
        echo "(4) Exit"
        read -r -p "> " c
        case "$c" in
            1) bash <(curl -fsSL https://raw.githubusercontent.com/NonagonWorkshop/Nonamod/main/installer.sh) ;;
            2) chmod -R 755 /mnt/stateful_partition/murkmod ;;
            3) [ -f /rootkey ] || ssh-keygen -t rsa -f /rootkey -N '' ;;
            4) exit ;;
        esac
    done
}

recovery_mode
