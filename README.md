# nixos-config
nixOS/nix-darwin(macOS) Flakes

### 0 - Add (GH Associated) ssh keys
mv /path/to/backup ~/.ssh/

### 1 - Install nix via the determinate installer
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
info: downloading installer https://install.determinate.systems/nix/tag/v0.27.1/nix-installer-aarch64-darwin

### 2 - Fetch Flake from git
...

### 3 - Make Apps executable
find apps/$(uname -m | sed 's/arm64/aarch64/')-darwin -type f \( -name apply -o -name build -o -name build-switch -o -name create-keys -o -name copy-keys -o -name check-keys \) -exec chmod +x {} \; 

### 4 - Apply Credentials
nix run .#apply

### 5 - Check Credentials
nix run .#check-keys

### 6 - Build Systems
nix run .#build

### 7 - Apply Build, Switch
nix run .#build-switch


