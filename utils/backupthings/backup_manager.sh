#!/usr/bin/env bash

ROOT="/mnt/stateful_partition/murkmod"
BACK="$ROOT/backups"

ensure_dirs() {
    [[ -d "$BACK" ]] || mkdir -p "$BACK" 2>/dev/null
}

load_backups() {
    ensure_dirs
    find "$BACK" -maxdepth 1 -type f -name "mushm_backup*.tar.gz" 2>/dev/null | sort
}

create_backup() {
    ensure_dirs

    t=$(date +"%Y%m%d-%H%M%S")
    pid=$$
    salt=$(date +%s | tail -c 5)

    name="mushm_backup_${t}_${pid}_${salt}.tar.gz"
    out="$BACK/$name"

    echo
    echo "Creating backup: $name"
    echo

    folders=(
        "plugins"
        "pollen"
    )

    files=(
        "/usr/bin/crosh crosh"
        "/sbin/chromeos_startup chromeos_startup"
        "/etc/opt/chrome/policies/managed managed_policies"
    )

    tar -czf "$out" -C "$ROOT" "${folders[@]}" 2>/dev/null

    for entry in "${files[@]}"; do
        src="${entry%% *}"
        arc="${entry##* }"

        [[ -e "$src" ]] && tar -czf "$out" -C "$(dirname "$src")" "$(basename "$src")" --append 2>/dev/null
    done

    echo "Backup complete: $name"
}

list_backups() {
    b=$(load_backups)

    stamp=$(date +"%H%M%S")
    echo
    echo "=== BACKUP LIST $stamp ==="
    echo

    if [[ -z "$b" ]]; then
        echo "No backups found."
        return
    fi

    while IFS= read -r line; do
        [[ -n "$line" ]] && echo "$(basename "$line")"
        sleep 0.02
    done <<< "$b"
}

restore_backup() {
    ensure_dirs

    mapfile -t b < <(load_backups)

    if [[ ${#b[@]} -eq 0 ]]; then
        echo "No backups available."
        return
    fi

    name="$1"

    if [[ -z "$name" ]]; then
        chosen="${b[-1]}"
    else
        chosen=""
        for x in "${b[@]}"; do
            [[ "$(basename "$x")" == "$name" ]] && chosen="$x"
        done

        if [[ -z "$chosen" ]]; then
            echo "Backup not found: $name"
            return
        fi
    fi

    echo
    echo "Restoring: $(basename "$chosen")"

    tar -xzf "$chosen" -C "$ROOT" 2>/dev/null

    echo "Restore complete: $(basename "$chosen")"
}

menu() {
    ensure_dirs

    while true; do
        echo
        echo "=== MURKMOD BACKUP MANAGER ==="
        echo "1) Create backup"
        echo "2) List backups"
        echo "3) Restore newest backup"
        echo "4) Restore specific backup"
        echo "5) Exit"
        echo

        read -r -p "Select option: " choice

        case "$choice" in
            1) create_backup ;;
            2) list_backups ;;
            3) restore_backup ;;
            4)
                read -r -p "Enter backup filename: " name
                restore_backup "$name"
                ;;
            5) exit 0 ;;
            *)
                echo "Invalid choice."
                sleep 0.1
                ;;
        esac
    done
}

menu
