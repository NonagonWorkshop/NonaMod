#!/bin/bash
# menu_plugin
PLUGIN_NAME="GBB Flag-inator"
PLUGIN_FUNCTION="Set your GBB flags"
PLUGIN_DESCRIPTION="Edit your GBB flags and set them to a specific order to allow specific things"
PLUGIN_AUTHOR="BinBashBanana"
PLUGIN_VERSION=1


read -p "What flags do you want to set? (e.g., 0x9d): " gbb_flags

if [ -z "$gbb_flags" ]; then
    echo "No flags entered. Exiting."
    exit 1
fi

# 3. Run the futility command using the user's option
echo "Setting GBB flags to $gbb_flags..."
futility gbb -s --flash --flags="$gbb_flags"

echo "GBB flags have been updated successfully."
