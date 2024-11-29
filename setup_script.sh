#!/usr/bin/env bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
_print() {
    echo -e "${2:-$GREEN}$1${NC}"
}

# Function to prompt user for input
_prompt() {
    local message="$1"
    local variable="$2"
    local default="$3"
    
    _print "$message" "$YELLOW"
    read -r response
    
    # Use default if response is empty and default is provided
    if [[ -z "$response" && -n "$default" ]]; then
        eval "$variable='$default'"
    else
        eval "$variable='$response'"
    fi
}

# Function to check command success
_check() {
    if [ $? -ne 0 ]; then
        _print "Error: $1" "$RED"
        exit 1
    fi
}

# Function to check if command exists
_command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to ensure admin privileges
ensure_admin() {
    if ! sudo -v; then
        _print "This script requires sudo privileges." "$RED"
        exit 1
    fi
    
    # Keep sudo alive
    (while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done) 2>/dev/null &
}

# Function to setup SSH directory
setup_ssh_dir() {
    local user="$1"
    local dir="/Users/$user/.ssh"
    
    if [ ! -d "$dir" ]; then
        sudo mkdir -p "$dir"
        sudo chmod 700 "$dir"
        sudo chown "$user:staff" "$dir"
    fi
}

# Function to install Nix
install_nix() {
    if [ ! -d "/nix" ]; then
        _print "Installing Nix..."
        curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
        _check "Failed to install Nix"
        
        # Source nix
        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
            . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        fi
    else
        _print "Nix is already installed"
    fi
}

# Main setup function
main() {
    _print "Starting NixOS/nix-darwin setup..."
    
    # Ensure we're on macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        _print "This script is intended for macOS only." "$RED"
        exit 1
    }
    
    # Ensure admin privileges
    ensure_admin
    
    # Install Xcode Command Line Tools if needed
    if ! _command_exists xcode-select; then
        _print "Installing Xcode Command Line Tools..."
        xcode-select --install
        _check "Failed to install Xcode Command Line Tools"
    fi
    
    # Install Nix
    install_nix
    
    # Setup Git credentials if needed
    if ! _command_exists git; then
        _print "Installing Git via Nix..."
        nix-env -iA nixpkgs.git
        _check "Failed to install Git"
    fi
    
    # Prompt for Git configuration if not set
    if [[ -z "$(git config --global user.name)" ]]; then
        _prompt "Enter your Git name:" GIT_NAME
        git config --global user.name "$GIT_NAME"
    fi
    
    if [[ -z "$(git config --global user.email)" ]]; then
        _prompt "Enter your Git email:" GIT_EMAIL
        git config --global user.email "$GIT_EMAIL"
    fi
    
    # Setup GitHub CLI
    if ! _command_exists gh; then
        _print "Installing GitHub CLI via Nix..."
        nix-env -iA nixpkgs.gh
        _check "Failed to install GitHub CLI"
        
        _print "Please authenticate with GitHub..."
        gh auth login
        gh auth setup-git
    fi
    
    # Clone repository
    _prompt "Enter the repository URL:" REPO_URL "https://github.com/dustinlyons/nixos-config.git"
    
    if [ ! -d "$(basename "$REPO_URL" .git)" ]; then
        git clone "$REPO_URL"
        _check "Failed to clone repository"
    fi
    
    cd "$(basename "$REPO_URL" .git)" || exit 1
    
    # Make apps executable
    _print "Making apps executable..."
    ARCH=$(uname -m | sed 's/arm64/aarch64/')
    find "apps/${ARCH}-darwin" -type f \( -name apply -o -name build -o -name build-switch -o -name create-keys -o -name copy-keys -o -name check-keys \) -exec chmod +x {} \;
    _check "Failed to make apps executable"
    
    # Run the configuration steps
    _print "Running configuration steps..."
    
    nix run .#create-keys
    _check "Failed to create keys"
    
    nix run .#apply
    _check "Failed to apply configuration"
    
    nix run .#build
    _check "Failed to build configuration"
    
    _print "Would you like to switch to the new configuration now? [Y/n]" "$YELLOW"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]] || [[ -z "$response" ]]; then
        nix run .#build-switch
        _check "Failed to switch configuration"
    fi
    
    _print "Setup completed successfully! Please restart your computer for all changes to take effect."
}

# Run main function
main "$@"