#!/bin/bash

# Function to check if a command was successful
check_command() {
    if [ $? -ne 0 ]; then
        echo "Error: $1"
        exit 1
    fi
} 

# Step 1: Create First User Account (Admin by default)
echo "Creating first user account (Admin)..."
username=$(whoami)
sudo sysadminctl -addUser "$username"
check_command "Failed to create first user account."

# Step 2: Create a separate (new) 'admin' account
echo "Creating admin account..."
# Check if the admin user already exists
if id "admin" &>/dev/null; then
    echo "Admin user already exists, skipping creation."
else
    read -sp "Enter password for the admin user: " admin_password
    echo  # for newline after password input
    sudo sysadminctl -addUser admin -admin -password "$admin_password"
    check_command "Failed to create admin account."
fi

# Step 3: Change First User Account to a Standard User Account
echo "Changing first user account to standard user..."
sudo dscl . -create /Users/"$username" UserShell /bin/bash
check_command "Failed to set user shell."
sudo dscl . -create /Users/"$username" UserType Standard
check_command "Failed to change user type."

# Step 4: Copy keys to "admin"
echo "Copying keys to admin account..."
read -p "Enter the path to backup keys: " backup_path

# Ensure .ssh directory exists for admin user
if [ ! -d /Users/admin/.ssh ]; then
    echo "Creating .ssh directory for admin user..."
    sudo mkdir -p /Users/admin/.ssh
    sudo chmod 700 /Users/admin/.ssh
    sudo chown admin:admin /Users/admin/.ssh
fi

# Check if backup path exists
if [ ! -d "$backup_path" ]; then
    echo "Error: Backup directory '$backup_path' does not exist."
    exit 1
fi

# Copy the entire directory (no globbing needed)
echo "Copying keys from '$backup_path' to /Users/admin/.ssh/"
sudo cp -r "$backup_path" /Users/admin/.ssh/
check_command "Failed to copy keys."

# Step 5: Change ownership of keys
echo "Changing ownership of keys..."
sudo chown -R admin:admin /Users/admin/.ssh/
check_command "Failed to change ownership of keys."

# Step 6: Install Xcode tools
echo "Checking if Xcode tools are installed..."
if ! xcode-select -p &>/dev/null; then
    echo "Installing Xcode tools..."
    xcode-select --install
    check_command "Failed to install Xcode tools."
else
    echo "Xcode tools are already installed, skipping installation."
fi

# Step 7: Check if Nix is installed (via /nix directory)
echo "Checking if Nix is installed..."
if [ -d "/nix" ]; then
    echo "Nix is already installed, skipping installation."
else
    echo "Installing Nix..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm --nix-build-group-id 3000
    check_command "Failed to install Nix."
fi

# Source the Nix daemon script to configure the environment
echo "Sourcing Nix daemon environment..."
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
check_command "Failed to source nix-daemon.sh."

# Step 8: Login via GitHub CLI and Setup Git
echo "Logging in via GitHub CLI and setting up Git credentials..."
nix-shell -p gh git --run "
    gh auth login --with-token
    gh auth setup-git
    git config --global user.name 'Your Name'
    git config --global user.email 'your-email@example.com'
"
check_command "Failed to authenticate with GitHub and set up Git credentials."

# Step 10: Fetch Flake from Git
echo "Fetching Flake from Git..."
read -p "Enter the repository URL: " repo_url
git clone "$repo_url"
repo_name=$(basename "$repo_url" .git)  # Extract the repo name from URL
cd "$repo_name" || exit 1  # If the cd fails, exit with error
check_command "Failed to clone repository."

# Step 11: Make Apps executable
echo "Making apps executable..."
find apps/$(uname -m | sed 's/arm64/aarch64/')-darwin -type f \( -name apply -o -name build -o -name build-switch -o -name create-keys -o -name copy-keys -o -name check-keys \) -exec chmod +x {} \;
check_command "Failed to make apps executable."

# Step 12: Apply Credentials
echo "Applying credentials..."
nix run .#apply
check_command "Failed to apply credentials."

# Step 13: Check Credentials
echo "Checking credentials..."
nix run .#check-keys
check_command "Failed to check credentials."

# Step 14: Build Systems
echo "Building systems..."
nix run .#build
check_command "Failed to build systems."

# Step 15: Apply Build, Switch
echo "Applying build and switch..."
nix run .#build-switch
check_command "Failed to apply build and switch."

echo "Setup completed successfully!"



