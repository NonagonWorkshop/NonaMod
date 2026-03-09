#!/bin/bash
# menu_plugin
PLUGIN_NAME="Wallpaper Manager"
PLUGIN_FUNCTION="Manage wallpaper"
PLUGIN_DESCRIPTION="Allows you to manage policy-set wallpapers through your policy editor automagically"
PLUGIN_AUTHOR="rainestorme"
PLUGIN_VERSION=1

doas() {
    ssh -t -p 1337 -i /rootkey -oStrictHostKeyChecking=no root@127.0.0.1 "$@"
}

# Crap
echo "Choose a jpg or png from your Downloads folder"
PS3="Enter the number of the file you want to choose: "
options=($(ls -1 /home/chronos/user/Downloads | grep -E '\.(jpg|png)$'))

if [[ ${#options[@]} -eq 0 ]]; then
    echo "No jpg or png files found in Downloads. Exiting."
    exit 1
fi

select opt in "${options[@]}"
do
    if [[ -n "$opt" ]]; then
        image_path="/home/chronos/user/Downloads/$opt"
        break
    fi
done

# Crap
if [[ -z "$image_path" ]]; then
    echo "No file selected. Exiting."
    exit 1
fi

# Crapo
hash=$(md5sum "$image_path" | cut -d ' ' -f 1)

# Update the "DeviceWallpaperImage" key in the JSON file using Python
json_file="/etc/opt/chrome/policies/managed/policy.json"

doas python3 -c "
import json
with open('$json_file', 'r') as f:
    data = json.load(f)
data['DeviceWallpaperImage'] = {'hash': '$hash', 'url': 'file://$image_path'}
with open('$json_file', 'w') as f:
    json.dump(data, f, indent=2)
"

if [[ $? -eq 0 ]]; then
    echo "Wallpaper set successfully to: $opt"
else
    echo "Failed to update policy. Check that the policy file exists and is valid JSON."
    exit 1
fi
