#!/bin/bash

# Function to print colored output
print_message() {
    local color=$1
    local message=$2
    tput setaf $color
    echo "$message"
    tput sgr0
}

# Function to load node version from package.json and set it using nvm
load_node_version() {
    local package_json_path="$(pwd)/package.json"
    local node_version
    
    # Check if $package_json_path file exists.
    if [ -f "$package_json_path" ]; then
        node_version=$(jq -r '.engines.node | select(.!=null)' "$package_json_path")
        if [ -z "$node_version" ]; then
            print_message 3 "package.json has no .engines.node version defined"
            return 1
            elif [[ $node_version == *"~"* || $node_version == *">"* || $node_version == *"^"* ]]; then
            print_message 3 "nvm does not support special characters (^, >, ~)"
            print_message 3 "No changes applied, please use nvm to set manually"
            print_message 3 "package.json .engines.node is $node_version"
            return 1
        else
            # Check if the version specification is a range
            if [[ $node_version == *" "* ]]; then
                # If it's a range, find the best matching version within the range
                local matched_version
                if [[ $node_version == *"lts"* ]]; then
                    matched_version=$(nvm version-remote --lts | grep -E "^v$node_version" | head -n 1)
                else
                    matched_version=$(nvm version-remote | grep -E "^v$node_version" | head -n 1)
                fi
                
                if [ -z "$matched_version" ]; then
                    print_message 3 "No matching Node.js version found for the specified range ($node_version)"
                    return 1
                fi
                
                node_version=$matched_version
            fi
            
            print_message 2 "This directory has a package.json file with .engines.node ($node_version)"
            nvm use $node_version
            return 0
        fi
    fi
    
    return 1
}

# Call the function to load node version
load_node_version

# Check if nvm command was successful and set NODE_VERSION_MODIFIED accordingly
if [ $? -eq 0 ]; then
    export NODE_VERSION_MODIFIED=true
else
    export NODE_VERSION_MODIFIED=false
fi

# Hook to automatically load node version when changing directories
add-zsh-hook chpwd load_node_version