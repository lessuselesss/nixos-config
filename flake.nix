{
  description = "Starter Configuration with secrets for MacOS and NixOS";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    agenix.url = "github:ryantm/agenix";
    home-manager.url = "github:nix-community/home-manager";
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-stable";
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
    homebrew-services.url = "github:homebrew/homebrew-services";
    homebrew-services.flake = false;
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
  };
  outputs = { self, darwin, nix-homebrew, homebrew-bundle, homebrew-core, homebrew-cask, homebrew-services, home-manager, nixpkgs, nixpkgs-stable, disko, agenix, secrets, pre-commit-hooks, nix-on-droid } @inputs:
    let
      user = "lessuseless";
      linuxSystems = [ "x86_64-linux" "aarch64-linux" "aarch64-android" ];
      darwinSystems = [ "aarch64-darwin" "x86_64-darwin" ];
      mobileSystems = [ "aarch64-linux" ];
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
            };
          };
        };
      in {
        default = with pkgs; mkShell {
          nativeBuildInputs = with pkgs; [ 
            bashInteractive 
            git 
            age 
            age-plugin-yubikey 
            nodejs
            nodePackages.npm
          ];
          shellHook = ''
            ${mkPreCommitHook.pre-commit-check.shellHook}
            export EDITOR=vim
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
      mkLinuxApps = system: {
        "apply" = mkApp "apply" system;
        "build-switch" = mkApp "build-switch" system;
      } // (if system != "aarch64-android" then {
        # Other Linux-specific apps
        "copy-keys" = mkApp "copy-keys" system;
        "create-keys" = mkApp "create-keys" system;
        "check-keys" = mkApp "check-keys" system;
        "install" = mkApp "install" system;
        "install-with-secrets" = mkApp "install-with-secrets" system;
      } else {});
      mkDarwinApps = system: {
        "apply" = mkApp "apply" system;
        "build" = mkApp "build" system;
        "build-switch" = mkApp "build-switch" system;
        "copy-keys" = mkApp "copy-keys" system;
        "create-keys" = mkApp "create-keys" system;
        "check-keys" = mkApp "check-keys" system;
        "rollback" = mkApp "rollback" system;
      };
    in
    {
      devShells = forAllSystems devShell;
      apps = nixpkgs.lib.genAttrs linuxSystems mkLinuxApps // nixpkgs.lib.genAttrs darwinSystems mkDarwinApps;

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
          };
        };
      });

      darwinConfigurations = nixpkgs.lib.genAttrs darwinSystems (system:
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = inputs;
          modules = [
            home-manager.darwinModules.home-manager
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                inherit user;
                enable = true;
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "homebrew/homebrew-bundle" = homebrew-bundle;
                  "homebrew/homebrew-services" = homebrew-services;
                };
                mutableTaps = false;
                autoMigrate = true;
              };
            }
            ./hosts/darwin
          ];
        }
      );

      nixosConfigurations = nixpkgs.lib.genAttrs linuxSystems (system: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = inputs;
        modules = [
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = import ./modules/nixos/home-manager.nix;
            };
          }
          ./hosts/nixos
        ];
     });

      nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
        modules = [ ./hosts/nix-on-droid/default.nix ];
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        extraSpecialArgs = {
          inherit inputs;
        };
      };
  };
}