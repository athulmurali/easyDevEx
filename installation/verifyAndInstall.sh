# Function to install missing dependencies
install_dependencies() {
    declare -A install_commands=(
        [brew]="echo | /bin/bash -c '$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)'"
        [zsh]="sh -c '$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)'"  # Adjust for other package managers
        [jq]="brew install jq"    # Adjust for other package managers
    )
    
    for dep in "${missing_dependencies[@]}"; do
        if [ -n "${install_commands[$dep]}" ]; then
            echo "Installing $dep..."
            eval "${install_commands[$dep]}"
            if [ $? -ne 0 ]; then
                echo "❌ Failed to install $dep. Please install it manually."
            else
                echo "✔️ $dep is installed successfully."
            fi
        else
            echo "❌ $dep is missing. Please install it manually."
        fi
    done
}

echo "Checking if required installations are present..."

# Check if brew, zsh, and jq are installed
missing_dependencies=()
if ! command -v brew &> /dev/null; then
    missing_dependencies+=("brew")
else
    echo "✔️ Brew is already installed."
fi
if ! command -v zsh &> /dev/null; then
    missing_dependencies+=("zsh")
else
    echo "✔️ Zsh is already installed."
fi
if ! command -v jq &> /dev/null; then
    missing_dependencies+=("jq")
else
    echo "✔️ JQ is already installed."
fi

# Output missing dependencies and installation instructions
if [ ${#missing_dependencies[@]} -gt 0 ]; then
    echo "Please install the following dependencies:"
    for dep in "${missing_dependencies[@]}"; do
        echo "- $dep"
    done
    
    read -p "Do you want to install these dependencies? (y/n): " choice
    case "$choice" in
        y|Y ) install_dependencies ;;
        n|N ) echo "Installation cancelled." ;;
        * ) echo "Invalid input. Installation cancelled." ;;
    esac
fi
