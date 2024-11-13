 # nixos-config
nixOS/nix-darwin(macOS) Flakes 

setup_script.sh will attempt to run all of the below, in the macOS terminal run:
`chmod +x setup_script.sh`

otherwise you can go through each step manually.  


# Steps
___
### 1. Create first User Account (Admin by default) account in macOS  

### 2. Create a separate (new) 'admin' account  
`sudo sysadminctl -addUser admin -admin`

### 3. Change first User Account to a standard user account

`sudo dscl . -create /Users/$(whoami) UserShell /bin/bash
sudo dscl . -create /Users/$(whoami) UserType Standard`

### 4. Login to standard user account via GUI

### 5. login to the admin account via terminal
`su - admin`

### 6. Copy keys to "admin"
`sudo mv ~/path/to/backup-keys/* /Users/admin/.ssh/`

### 7. Change ownership of keys
`sudo chown admin:admin /Users/admin/.ssh/id_ed25519 \
&& sudo chown admin:admin /Users/admin/.ssh/id_ed25519.pub \
&& sudo chown admin:admin /Users/admin/.ssh/id_ed25519_agenix \
&& sudo chown admin:admin /Users/admin/.ssh/id_ed25519_agenix.pub`

### 8. Install tools
`xcode-select --install`

### 8. Install nix via the determinate installer
`curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm --nix-build-group-id 4000`

### 9. Login via gh
`nix-shell -p gh git`

### 10. Set git credentials 
`gh auth setup-git`

### 11. Fetch Flake from git
`git clone <repository-url>
cd <repository-directory>`

### 12. Make Apps executable
`find apps/$(uname -m | sed 's/arm64/aarch64/')-darwin -type f \( -name apply -o -name build -o -name build-switch -o -name create-keys -o -name copy-keys -o -name check-keys \) -exec chmod +x {} \;`

### 13. Apply Credentials
`nix run .#apply`

### 14. Check Credentials
`nix run .#check-keys`

### 15. Build Systems
`nix run .#build`

### 16. Apply Build, Switch
`nix run .#build-switch`


