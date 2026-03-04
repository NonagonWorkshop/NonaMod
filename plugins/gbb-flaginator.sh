#!/bin/bash
# menu_plugin
PLUGIN_NAME="GBB Flag-inator"
PLUGIN_FUNCTION="set_gbb_flags" # The function NonaMod will call
PLUGIN_DESCRIPTION="Edit your GBB flags and set them to a specific order to allow specific things"
PLUGIN_AUTHOR="BinBashBanana"
PLUGIN_VERSION=1

set_gbb_flags() {
    # 1. Ask the person for input
    # Ask the question or whatever'
    read -p "What flags do you want to set? (e.g. 0x9d): " gbb_flags

    # 2. Check if the user entered any input
    if [ -z "$gbb_flags" ]; then
        echo "No flags entered. Returning to menu."
        return 1
    fi

    # 3. Execution the crap
    echo "Setting GBB flags to $gbb_flags..."
    
    # Using 'futility to write shit
    if futility gbb -s --flash --flags="$gbb_flags"; then
        echo "GBB flags have been updated successfully."
    else
        echo "Failed to set GBB flags. Are you running as root/with proper permissions?"
    fi
}
