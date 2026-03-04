#!/bin/bash
# menu_plugin
PLUGIN_NAME="GBB Flag-inator"
PLUGIN_FUNCTION="set_gbb_flags"
PLUGIN_DESCRIPTION="Edit your GBB flags and set them to a specific order"
PLUGIN_AUTHOR="BinBashBanana"
PLUGIN_VERSION=1

# I guess the name must match the function lol
set_gbb_flags() {
    clear
    echo "--- GBB Flag-inator ---"
    
    read -p "What flags do you want to set? (e.g., 0x9d): " gbb_flags

    if [ -z "$gbb_flags" ]; then
        echo "No flags entered. Returning to menu..."
        sleep 2
        return
    fi

    echo "Attempting to set GBB flags to $gbb_flags..."
    
    # Use futility to talk to sudo and whatnot
    if sudo futility gbb -s --flash --flags="$gbb_flags"; then
        echo "Success! GBB flags updated."
    else
        echo "Error: Failed to set flags. Make sure Write-Protect is OFF."
    fi
    
    echo "Press Enter to return to the menu."
    read
}
