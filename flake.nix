{
  description = "Starter Configuration with secrets for MacOS and NixOS";

  inputs = {
    # Use flakehub for nixpkgs for better performance and versioning
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "https://flakehub.com/f/NixOS/nixpkgs/*";
    nixpkgs-unstable.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";
    # Use Determinate systems for experimental features
    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/0.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fh.url = "https://flakehub.com/f/DeterminateSystems/fh/*";
    # TODO: Add apple-silicon-support to flakehub
    apple-silicon-support = {
      url = "github:tpwrules/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix.url = "github:ryantm/agenix";
    home-manager.url = "github:nix-community/home-manager";
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-services = {
      url = "github:homebrew/homebrew-services";
      flake = false;
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    secrets = {
      url = "git+ssh://git@github.com/lessuselesss/nix-secrets.git?ref=main";
      flake = false;
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    johnny-mnemonix = {
      url = "github:lessuselesss/johnny-mnemonix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    determinate,
    fh,
    nixpkgs,
    nixpkgs-stable,
    nixpkgs-unstable,
    apple-silicon-support,
    agenix,
    home-manager,
    darwin,
    nix-homebrew,
    homebrew-bundle,
    homebrew-core,
    homebrew-cask,
    homebrew-services,
    disko,
    secrets,
    pre-commit-hooks,
    nix-on-droid,
    johnny-mnemonix,
  } @ inputs: let
    adminUser = "admin";
    standardUser = "lessuseless";
    linuxSystems = ["x86_64-linux" "aarch64-linux"];
    darwinSystems = ["aarch64-darwin" "x86_64-darwin"];
    mobileSystems = ["aarch64-linux"];
    forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems ++ mobileSystems) f;

    devShell = system: let
      pkgs = nixpkgs.legacyPackages.${system};
      mkPreCommitHook = {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            repomix-generator = {
              enable = true;
              name = "repomix-generator";
              entry = "${pkgs.writeShellScript "generate-repomix" ''
                ${pkgs.nodejs}/bin/node ${pkgs.nodePackages.npm}/bin/npx repomix .
                git add repomix-output.txt
              ''}";
              files = ".*";
              pass_filenames = false;
            };
            alejandra-lint = {
              enable = true;
              name = "alejandra-lint";
              entry = "${pkgs.alejandra}/bin/alejandra .";
              files = ".*";
              pass_filenames = false;
            };
            build-check = {
              enable = true;
              name = "build-check";
              entry = "${pkgs.writeShellScript "verify-build" ''
                echo "Verifying build..."
                nix run .#build  # Changed to build-switch
              ''}";
              files = ".*";
              pass_filenames = false;
            };
          };
        };
      };
    in {
      default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          bashInteractive
          git
          age
          age-plugin-yubikey
          age-plugin-ledger
          nodejs_23
          nodePackages.npm
        ];
        shellHook = ''
          ${mkPreCommitHook.pre-commit-check.shellHook}
          export EDITOR=vim
          git config --unset-all core.hooksPath || true
        '';
      };
    };

    mkApp = scriptName: system: {
      type = "app";
      program = "${(nixpkgs.legacyPackages.${system}.writeScriptBin scriptName ''
        #!/usr/bin/env bash
        PATH=${nixpkgs.legacyPackages.${system}.git}/bin:$PATH
        echo "Running ${scriptName} for ${system}"
        # Detect if we're on Android
        if [[ -n "$TERMUX_VERSION" ]]; then
          exec ${self}/apps/aarch64-android/${scriptName}
        else
          exec ${self}/apps/${system}/${scriptName}
        fi
      '')}/bin/${scriptName}";
    };

    mkLinuxApps = system:
      {
        apply = mkApp "apply" system;
        "build-switch" = mkApp "build-switch" system;
      }
      // (
        if system != "aarch64-android"
        then {
          "copy-keys" = mkApp "copy-keys" system;
          "create-keys" = mkApp "create-keys" system;
          "check-keys" = mkApp "check-keys" system;
          install = mkApp "install" system;
          "install-with-secrets" = mkApp "install-with-secrets" system;
        }
        else {}
      );

    mkDarwinApps = system: {
      apply = mkApp "apply" system;
      build = mkApp "build" system;
      "build-switch" = mkApp "build-switch" system;
      "copy-keys" = mkApp "copy-keys" system;
      "create-keys" = mkApp "create-keys" system;
      "check-keys" = mkApp "check-keys" system;
      rollback = mkApp "rollback" system;
    };
  in {
    devShells = forAllSystems devShell;
    apps = (nixpkgs.lib.genAttrs linuxSystems mkLinuxApps) // (nixpkgs.lib.genAttrs darwinSystems mkDarwinApps);

    checks = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          repomix-generator = {
            enable = true;
            name = "repomix-generator";
            entry = "${pkgs.writeShellScript "generate-repomix" ''
              ${pkgs.nodejs}/bin/node ${pkgs.nodePackages.npm}/bin/npx repomix .
              git add repomix-output.txt
            ''}";
            files = ".*";
            pass_filenames = false;
          };
          alejandra-lint = {
            enable = true;
            name = "alejandra-lint";
            entry = "${pkgs.alejandra}/bin/alejandra .";
            files = ".*";
            pass_filenames = false;
          };
          build-check = {
            enable = true;
            name = "build-check";
            entry = "${pkgs.writeShellScript "verify-build" ''
              echo "Verifying build..."
              nix run .#build-switch  # Changed to build-switch
            ''}";
            files = ".*";
            pass_filenames = false;
          };
        };
      };
    });

    darwinConfigurations = nixpkgs.lib.genAttrs darwinSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowBroken = true;
          allowInsecure = false;
          allowUnsupportedSystem = true;
        };
        overlays = let
          path = ./overlays;
        in
          with builtins;
            map (n: import (path + ("/" + n)))
            (filter (n:
              match ".*\\.nix" n
              != null
              || pathExists (path + ("/" + n + "/default.nix")))
            (attrNames (readDir path)));
      };
    in
      darwin.lib.darwinSystem {
        inherit system;
        specialArgs = inputs // {inherit pkgs;};
        modules = [
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew
          ./modules/shared/johnny-mnemonix.nix
          agenix.darwinModules.default
          {
            _module.args.pkgs = pkgs;
            johnny-mnemonix.enable = true;
            nix.enable = false;
            nix.gc.automatic = false;

            # Configure admin user with sudo privileges
            users.users.${adminUser} = {
              home = "/Users/${adminUser}";
              shell = pkgs.zsh;
              # Add to admin group for sudo privileges
              gid = 80; # 80 is the admin group on macOS
            };

            # Configure standard user without sudo privileges
            users.users.${standardUser} = {
              home = "/Users/${standardUser}";
              shell = pkgs.zsh;
            };

            # Configure home-manager for both users
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = inputs // {inherit pkgs;};
              users = {
                ${adminUser} = import ./users/admin.nix;
                ${standardUser} = import ./users/lessuseless.nix;
              };
            };

            # Configure Homebrew to be owned by admin user
            nix-homebrew = {
              enable = true;
              user = adminUser;
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "homebrew/homebrew-bundle" = homebrew-bundle;
                "homebrew/homebrew-services" = homebrew-services;
              };
              mutableTaps = false;
              autoMigrate = true;
            };

            # System-wide security settings
            security.pam.services.sudo_local.touchIdAuth = true;
          }
          ./hosts/darwin
        ];
      });

    nixosConfigurations = nixpkgs.lib.genAttrs linuxSystems (system:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = inputs;
        modules = [
          determinate.nixosModules.default
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          johnny-mnemonix.nixosModules.default
          {
            johnny-mnemonix.enable = true;
            hardware.asahi.enable = system == "aarch64-linux";
            hardware.asahi.pkgsSystem = system;

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = inputs;
              users = {
                ${adminUser} = import ./users/admin.nix;
                ${standardUser} = import ./users/lessuseless.nix;
              };
            };
          }
          ./hosts/nixos
        ];
      });

    nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
      modules = [./hosts/nix-on-droid/default.nix];
      pkgs = nixpkgs.legacyPackages.aarch64-linux;
      extraSpecialArgs = {inherit inputs;};
    };
  };
}
