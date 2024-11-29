# nixos-config
NixOS, nix-darwin (macOS), Nix-on-Droid (Android), and qubesos-template (QubesOS) configuration using Flakes

## Prerequisites

- For macOS: A clean macOS installation
- For NixOS: A fresh NixOS installation
- Git
- SSH keys for accessing private repositories (optional)

## Quick Start (macOS)

For automated setup, use the provided script:

```bash
chmod +x setup_script.sh
./setup_script.sh
```

## Manual Setup

### 1. Install Nix
Install Nix using the determinate systems installer:
```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

### 2. Clone the Repository
```bash
git clone https://github.com/your-username/nixos-config.git
cd nixos-config
```

### 3. Development Environment
This repository uses pre-commit hooks to maintain consistency and generate IDE helper files. To set up the development environment:

```bash
nix develop
```

This will:
- Set up the pre-commit hooks
- Generate the `repomix-output.txt` file for Cursor IDE integration
- Provide necessary development tools (age, yubikey support, etc.)

### 4. Configuration Steps

#### For macOS:
1. Build the initial configuration:
```bash
nix run .#build
```

2. Apply the configuration:
```bash
nix run .#build-switch
```

3. If using secrets:
```bash
# Generate new keys
nix run .#create-keys

# Verify keys are properly set up
nix run .#check-keys

# Apply secrets configuration
nix run .#apply
```

#### For NixOS:
1. Apply the configuration:
```bash
nix run .#apply
```

2. Build and switch to the new configuration:
```bash
nix run .#build-switch
```

## Development Workflow

1. Always use `nix develop` when making changes to ensure pre-commit hooks are active

2. The pre-commit hooks will:
   - Automatically generate `repomix-output.txt` for  streamlined Cursor IDE integration
   - Stage the generated file for commit

3. Available development commands:
   - `nix run .#build` - Build configuration
   - `nix run .#build-switch` - Build and activate configuration
   - `nix run .#rollback` - Rollback to previous configuration (macOS only)

## Repository Structure

```
├── apps/                   # Platform-specific scripts
├── hosts/                  # Host-specific configurations
│   ├── darwin/             # macOS configurations
│   ├── nix-on-droid/       # Android configurations
│   ├── nixos/              # NixOS configurations
│   └── qubes-templatevm/   # QubesOS template configurations
├── modules/                # Shared configuration modules
├── flake.nix               # Main flake configuration
└── flake.lock            # Locked dependencies
```

## Secrets Management

This configuration uses `agenix` for secrets management. To work with secrets:

1. Ensure you have the necessary keys in `~/.ssh/`
2. Use `nix run .#create-keys` to generate new keys
3. Use `nix run .#check-keys` to verify key setup
4. Use `nix run .#apply` to apply secrets configuration

## Contributing

1. Fork the repository
2. Create a new branch for your changes
3. Use `nix develop` to set up the development environment
4. Make your changes
5. Commit and push your changes
6. Submit a pull request

## Troubleshooting

If you encounter issues:

1. Ensure Nix is properly installed: `nix --version`
2. Verify you're in a `nix develop` shell when making changes
3. Check system logs: `darwin-rebuild changelog` (macOS) or `journalctl` (NixOS)
4. For rollback on macOS: `nix run .#rollback`