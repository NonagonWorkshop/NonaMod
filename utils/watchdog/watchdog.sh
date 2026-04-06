#!/bin/bash

main="/usr/bin/crosh"
recovery="/mnt/stateful_partition/murkmod/mushm_recovery.sh"

while true; do
    bash "$main" &
    pid=$!
    wait $pid
    code=$?
    if [ "$code" -ne 0 ]; then
        cp "$recovery" "$main"
        chmod +x "$main"
        bash "$main"
    fi
    sleep 1
done
