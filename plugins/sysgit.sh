#!/bin/bash
# menu_plugin
PLUGIN_NAME="GBB Flag-inator"
PLUGIN_FUNCTION="Set GBB Flags"
PLUGIN_DESCRIPTION="Edit your GBB flags and set them to a specific order"
PLUGIN_AUTHOR="BinBashBanana"
PLUGIN_VERSION=1

# Clear the screen etc
clear
echo "--- GBB Flag-inator ---"

# 1. Ask for the the flags they want set
read -p "What flags do you want to set? (e.g., 0x9d): " gbb_flags

# 2. Check if the user entered anything
if [ -z "$gbb_flags" ]; then
    echo "No input detected. Returning to menu..."
    sleep 2
else
    # 3. Execute the command
    echo "Applying GBB flags: $gbb_flags"
    sudo futility gbb -s --flash --flags="$gbb_flags"

    # 4. PAUSE and whatnot
    echo ""
    echo "Done! Press [Enter] to return to the menu."
    read
fi
