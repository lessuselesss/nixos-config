 # nixos-config
nixOS/nix-darwin(macOS) Flakes 

# Steps
___
### 1. Create first User Account (Admin by default) account in macOS  

### 2. Create a separate (new) 'admin' account  

### 3. Change first User Account to a standard user account

### 4. Login to standard user account

### 5. login to the admin account via terminal
`su - admin`

### 6. Copy keys to "admin"
`sudo mv ~/path/to/backup-keys/* /Users/admin/.ssh/`

### 7. Change ownership of keys
`sudo chown admin:admin /Users/admin/.ssh/id_ed25519 && sudo chown admin:admin /Users/admin/.ssh/id_ed25519.pub && sudo chown admin:admin /Users/admin/.ssh/id_ed25519_agenix && chown admin:admin /Users/admin/.ssh/id_ed25519_agenix.pub`

### 8. Install tools
`xcode-select --install`

### 8. Install nix via the determinate installer
`curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
info: downloading installer https://install.determinate.systems/nix/tag/v0.27.1/nix-installer-aarch64-darwin`

### 9. Login via gh
`nix-shell -p gh git`

### 10. Set git credentials 
`gh auth setup-git`

### 11. Fetch Flake from git
...

### 12. Make Apps executable
find apps/$(uname -m | sed 's/arm64/aarch64/')-darwin -type f \( -name apply -o -name build -o -name build-switch -o -name create-keys -o -name copy-keys -o -name check-keys \) -exec chmod +x {} \; 

### 13. Apply Credentials
`nix run .#apply`

### 14. Check Credentials
`nix run .#check-keys`

### 15. Build Systems
`nix run .#build`

### 16. - Apply Build, Switch
`nix run .#build-switch`


