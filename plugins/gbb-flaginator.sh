#!/bin/bash
# menu_plugin
PLUGIN_NAME="GBB Flag-inator"
PLUGIN_FUNCTION="Set GBB Flags"
PLUGIN_DESCRIPTION="Edit your GBB flags and set them to a specific order"
PLUGIN_AUTHOR="BinBashBanana"
PLUGIN_VERSION=1

# Take the code in the function you have above
Set GBB Flags() {
    # Clear the screen because it will let you see better ofc
    clear
    echo "--- GBB Flag-inator ---"
    
    # Prompt the user and ask what flags they want set like 0x9d
    read -p "What flags do you want to set? (e.g., 0x9d): " gbb_flags

    if [ -z "$gbb_flags" ]; then
        echo "No flags entered. Returning to menu..."
        sleep 2
        return 1
    fi

    echo "Setting GBB flags to $gbb_flags..."
    
    # Run the command
    # Note: R117+ Chromeos requires VT2 (Ctrl+Alt+F2) for sudo/futility command crap
    if sudo futility gbb -s --flash --flags="$gbb_flags"; then
        echo "GBB flags updated successfully."
    else
        echo "Error: Failed to set flags. Is write-protect disabled?"
    fi
    
    # Make sure they read results before letting them exit
    echo "Press Enter to return to the menu."
    read
}
