#!/bin/bash

# Function to check if a command was successful
check_command() {
    if [ $? -ne 0 ]; then
        echo "Error: $1"
        exit 1
    }
}

# Step 1: Create First User Account (Admin by default)
echo "Creating first user account (Admin)..."
username=$(whoami)
sudo sysadminctl -addUser "$username"
check_command "Failed to create first user account."

# Step 2: Create a separate (new) 'admin' account
echo "Creating admin account..."
sudo sysadminctl -addUser admin -admin
check_command "Failed to create admin account."

# Step 3: Change First User Account to a Standard User Account
echo "Changing first user account to standard user..."
sudo dscl . -create /Users/"$username" UserShell /bin/bash
check_command "Failed to set user shell."
sudo dscl . -create /Users/"$username" UserType Standard
check_command "Failed to change user type."

# Step 4: Copy keys to "admin"
echo "Copying keys to admin account..."
read -p "Enter the path to backup keys: " backup_path
sudo cp -rf "$backup_path"/* /Users/admin/.ssh/
check_command "Failed to copy keys."

# Step 5: Change ownership of keys
echo "Changing ownership of keys..."
sudo chown admin:admin /Users/admin/.ssh/id_ed25519 \
&& sudo chown admin:admin /Users/admin/.ssh/id_ed25519.pub \
&& sudo chown admin:admin /Users/admin/.ssh/id_ed25519_agenix \
&& sudo chown admin:admin /Users/admin/.ssh/id_ed25519_agenix.pub
check_command "Failed to change ownership of keys."

# Step 6: Install Xcode tools
echo "Installing Xcode tools..."
xcode-select --install
check_command "Failed to install Xcode tools."

# Step 7: Install Nix via the Determinate Installer
echo "Installing Nix..."
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
check_command "Failed to install Nix."

# Step 8: Login via GitHub CLI
echo "Logging in via GitHub CLI..."
nix-shell -p gh git
check_command "Failed to enter Nix shell."

# Step 9: Set Git credentials
echo "Setting up Git credentials..."
gh auth setup-git
check_command "Failed to set up Git credentials."

# Step 10: Fetch Flake from Git
echo "Fetching Flake from Git..."
read -p "Enter the repository URL: " repo_url
git clone "$repo_url"
cd "$(basename "$repo_url" .git) || exit
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
