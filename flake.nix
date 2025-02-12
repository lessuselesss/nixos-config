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
    johnny-mnemonix = {
      url = "github:lessuselesss/johnny-mnemonix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    python-packages = {
      url = "github:NixOS/nixpkgs";
      follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    darwin,
    nix-homebrew,
    homebrew-bundle,
    homebrew-core,
    homebrew-cask,
    homebrew-services,
    home-manager,
    nixpkgs,
    nixpkgs-stable,
    disko,
    agenix,
    secrets,
    pre-commit-hooks,
    nix-on-droid,
    johnny-mnemonix,
    python-packages,
  } @ inputs: let
    user = "lessuseless";
    linuxSystems = ["x86_64-linux" "aarch64-linux" "aarch64-android"];
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
                nix run .#build
              ''}";
              files = ".*";
              pass_filenames = false;
            };
          };
        };
      };
    in {
      default = with pkgs;
        mkShell {
          nativeBuildInputs = with pkgs; [
            bashInteractive
            git
            age
            age-plugin-yubikey
            nodejs_23
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
    mkLinuxApps = system:
      {
        "apply" = mkApp "apply" system;
        "build-switch" = mkApp "build-switch" system;
      }
      // (
        if system != "aarch64-android"
        then {
          # Other Linux-specific apps
          "copy-keys" = mkApp "copy-keys" system;
          "create-keys" = mkApp "create-keys" system;
          "check-keys" = mkApp "check-keys" system;
          "install" = mkApp "install" system;
          "install-with-secrets" = mkApp "install-with-secrets" system;
        }
        else {}
      );
    mkDarwinApps = system: {
      "apply" = mkApp "apply" system;
      "build" = mkApp "build" system;
      "build-switch" = mkApp "build-switch" system;
      "copy-keys" = mkApp "copy-keys" system;
      "create-keys" = mkApp "create-keys" system;
      "check-keys" = mkApp "check-keys" system;
      "rollback" = mkApp "rollback" system;
    };
  in {
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
              nix run .#build
            ''}";
            files = ".*";
            pass_filenames = false;
          };
        };
      };
    });

    darwinConfigurations = nixpkgs.lib.genAttrs darwinSystems (
      system:
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = inputs;
          modules = [
            home-manager.darwinModules.home-manager
            nix-homebrew.darwinModules.nix-homebrew
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = {
                  inherit (inputs) home-manager;
                };
                users.${user} = {
                  config,
                  pkgs,
                  ...
                }: {
                  _module.args.homeManagerLib = home-manager.lib;
                  imports = [
                    johnny-mnemonix.homeManagerModules.default
                  ];

                  johnny-mnemonix = {
                    enable = true;
                    baseDir = "/Users/${user}/Documents";
                    spacer = " ";

                    xdg = {
                      stateHome = config.home.homeDirectory + "/.local/state";
                      cacheHome = config.home.homeDirectory + "/.cache";
                      configHome = config.home.homeDirectory + "/.config";
                    };

                    areas = {
                      # System - About the system.
                      "00-09" = {
                        name = "_System_";
                        categories = {
                          "00" = {
                            name = "[Meta]";
                            items = {
                              "00.00" = {
                                name = "Nixos-config";
                                url = "https://github.com/lessuselesss/nixos-config";
                                ref = "main";
                              };
                              "00.01" = {
                                name = "Logs";
                                target = "/var/log";
                              };
                              "00.02" = {
                                name = "QubesOS-config";
                                url = "https://github.com/lessuselesss/qubesos-config";
                                ref = "main";
                              };
                              "00.03" = {
                                name = "Workflows";
                              };
                              "00.04" = {
                                name = "VMs";
                              };
                            };
                          };
                          "01" = {
                            name = "[Home]";
                            items = {
                              "01.00" = {
                                name = "Dotfiles";
                                target = "/Users/${user}/.dotfiles";
                              };
                              "01.01" = {
                                name = "Applications";
                                target = "/Users/${user}/Applications";
                              };
                              "01.02" = {
                                name = "Desktop";
                                target = "/Users/${user}/Desktop";
                              };
                              "01.03" = {
                                name = "Documents";
                                target = "/Users/${user}/Documents";
                              };
                              "01.04" = {
                                name = "Downloads";
                                target = "/Users/${user}/.local/share/downloads";
                              };
                              "01.05" = {
                                name = "Movies";
                                target = "/Users/${user}/Movies";
                              };
                              "01.06" = {
                                name = "Music";
                                target = "/Users/${user}/Music";
                              };
                              "01.07" = {
                                name = "Pictures";
                                target = "/Users/${user}//Pictures";
                              };
                              "01.08" = {
                                name = "Public";
                                target = "/Users/${user}/Public";
                              };
                              "01.09" = {
                                name = "Templates";
                                target = "/Users/${user}/Templates";
                              };
                              "01.10" = {
                                name = "Local Share";
                                target = "/Users/${user}/.local/share";
                              };
                              "01.11" = {
                                name = "Local Bin";
                                target = "/Users/${user}/.local/bin";
                              };
                              "01.12" = {
                                name = "Local Lib";
                                target = "/Users/${user}/.local/lib";
                              };
                              "01.13" = {
                                name = "Local Include";
                                target = "/Users/${user}/.local/include";
                              };
                              "01.14" = {
                                name = "Local State";
                                target = "/Users/${user}/.local/state";
                              };
                              "01.15" = {
                                name = "Local Cache";
                                target = "/Users/${user}/.cache";
                              };
                            };
                          };
                          "02" = {
                            name = "[Cloud]";
                            items = {
                              "02.00" = {
                                name = "configs";
                                target = "/Users/${user}/.config/rclone";
                              };
                              "02.01" = {
                                name = "Dropbox";
                              };
                              "02.02" = {
                                name = "Google Drive";
                              };
                              "02.03" = {
                                name = "iCloud";
                                target = "/Users/${user}/Library/Mobile Documents/com~apple~CloudDocs";
                              };
                            };
                          };
                        };
                      };

                      # Projects - Short-term efforts in your work or life that you're working on now.
                      "10-19" = {
                        name = "_Projects_";
                        categories = {
                          "11" = {
                            name = "[Maintaining]";
                            items = {
                              "11.01" = {
                                name = "Johnny-Mnemonix";
                                url = "https://github.com/lessuselesss/johnny-mnemonix";
                                ref = "main";
                              };
                              "11.02" = {
                                name = "Forks";
                              };
                              # "11.03" = {
                              #   name = "Anki Sociology";
                              #   url = "https://github.com/lessuselesss/anki-sociology100";
                              #   ref = "main";
                              # };
                              "11.04" = {
                                name = "Anki Ori's Decks";
                                url = "https://github.com/lessuselesss/anki-ori_decks";
                                ref = "main";
                              };
                              "11.05" = {
                                name = "Claude Desktop";
                                url = "https://github.com/lessuselesss/claude_desktop";
                                ref = "main";
                              };
                              "11.06" = {
                                name = "Dygma Raise - Miryoku";
                                url = "https://github.com/lessuselesss/dygma-raise-miryoku";
                                ref = "main";
                              };
                              "11.07" = {
                                name = "Uber-FZ_SD-Files";
                                url = "https://github.com/lessuselesss/Uber-FZ_SD-Files";
                                ref = "main";
                              };
                              "11.08" = {
                                name = "nix-node";
                                url = "https://github.com/lessuselesss/nix-node";
                                ref = "master";
                              };
                            };
                          };
                          "12" = {
                            name = "[Contributing]";
                            items = {
                              "12.01" = {
                                name = "Screenpipe";
                                url = "https://github.com/lessuselesss/screenpipe";
                                ref = "main";
                              };
                              "12.02" = {
                                name = "ai16z-main";
                                url = "https://github.com/ai16z/eliza.git";
                                ref = "main";
                              };
                              "12.03" = {
                                name = "ai16z-develop";
                                url = "https://github.com/ai16z/eliza.git";
                                ref = "develop";
                              };
                              "12.04" = {
                                name = "ai16z-fork";
                                url = "https://github.com/lessuselesss/eliza.git";
                                ref = "main";
                              };
                              "12.05" = {
                                name = "ai16z-characterfile";
                                url = "https://github.com/lessuselesss/characterfile.git";
                                ref = "main";
                              };
                              "12.06" = {
                                name = "Fabric";
                                url = "https://github.com/lessuselesss/fabric";
                                ref = "main";
                              };
                              "12.07" = {
                                name = "Whisper Diarization";
                                url = "https://github.com/lessuselesss/whisper-diarization";
                                ref = "main";
                              };
                            };
                          };
                          "13" = {
                            name = "[Using]";
                            items = {
                              "13.01" = {
                                name = "Bon-Jailbreaking";
                                url = "https://github.com/jplhughes/bon-jailbreaking";
                                ref = "main";
                              };
                            };
                          };
                        };
                      };

                      # Areas - Long-term responsibilities you want to manage over time.
                      "20-29" = {
                        name = "_Areas_";
                        categories = {
                          "21" = {
                            name = "[Personal]";
                            items = {
                              "21.01" = {
                                name = "Health";
                              };
                              "21.02" = {
                                name = "Finance";
                              };
                              "21.03" = {
                                name = "Family";
                              };
                            };
                          };
                          "22" = {
                            name = "[Professional]";
                            items = {
                              "22.01" = {
                                name = "Career";
                                url = "https://github.com/lessuselesss/careerz";
                              };
                              "22.02" = {
                                name = "Skills";
                              };
                            };
                          };
                        };
                      };

                      # Topics or interests that may be useful in the future.
                      "30-39" = {
                        name = "_Resources_";
                        categories = {
                          "30" = {
                            name = "[Devenv_Repos]";
                            items = {
                              "30.01" = {
                                name = "RWKV-Runner";
                                url = "https://github.com/lessuselesss/RWKV-Runner";
                                ref = "master";
                              };
                              "30.02" = {
                                name = "exo";
                                url = "https://github.com/lessuselesss/exo";
                                ref = "main";
                              };
                            };
                          };
                          "31" = {
                            name = "[References]";
                            items = {
                              "31.01" = {
                                name = "Technical";
                              };
                              "31.02" = {
                                name = "Academic";
                              };
                            };
                          };
                          "32" = {
                            name = "[Collections]";
                            items = {
                              "32.01" = {
                                name = "Templates";
                              };
                              "32.02" = {
                                name = "Checklists";
                              };
                            };
                          };
                        };
                      };

                      # Archive - Completed projects, references, and other resources that you no longer need to manage actively.
                      "90-99" = {
                        name = "_Archive_";
                        categories = {
                          "90" = {
                            name = "[Completed]";
                            items = {
                              "90.01" = {
                                name = "Projects";
                              };
                              "90.02" = {
                                name = "References";
                              };
                            };
                          };
                          "91" = {
                            name = "[Deprecated]";
                            items = {
                              "91.01" = {
                                name = "Old Documents";
                              };
                              "91.02" = {
                                name = "Legacy Files";
                              };
                            };
                          };
                          "92" = {
                            name = "[Models]";
                            items = {
                              "92.01" = {
                                name = "Huggingface";
                              };
                              "92.02" = {
                                name = "Ollama";
                              };
                            };
                          };
                          "93" = {
                            name = "[Datasets]";
                            items = {
                              "93.01" = {
                                name = "Kaggle";
                              };
                              "93.02" = {
                                name = "x";
                              };
                            };
                          };
                        };
                      };
                    };
                  };
                };
              };

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

    nixosConfigurations = nixpkgs.lib.genAttrs linuxSystems (
      system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = inputs;
          modules = [
            disko.nixosModules.disko
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = {
                  inherit (inputs) home-manager;
                };
                users.${user} = {
                  config,
                  pkgs,
                  ...
                }: {
                  _module.args.homeManagerLib = home-manager.lib;
                  imports = [
                    johnny-mnemonix.homeManagerModules.default
                  ];

                  #   johnny-mnemonix = {
                  #     enable = true;
                  #     baseDir = "/home/${user}/Documents/"; # Darwin's user home directory = /Users/${user}/
                  #     spacer = " ";

                  #     xdg = {
                  #       stateHome = config.home.homeDirectory + "/.local/state";
                  #       cacheHome = config.home.homeDirectory + "/.cache";
                  #       configHome = config.home.homeDirectory + "/.config";
                  #     };

                  #     areas = {
                  #       # System - About the system.
                  #       "00-09" = {
                  #         name = "_System_";
                  #         categories = {
                  #           "00" = {
                  #             name = "[Meta]";
                  #             items = {
                  #               "00.01" = {
                  #                 name = "Placeholder";
                  #               };
                  #               "00.02" = {
                  #                 name = "Placeholder";
                  #               };
                  #             };
                  #           };
                  #           "01" = {
                  #             name = "[Home]";
                  #             items = {
                  #               "01.00" = {
                  #                 name = "Dotfiles";
                  #                 target = "/home/test/.dotfiles";
                  #               };
                  #               "01.01" = {
                  #                 name = "Applications";
                  #                 target = "/home/test/Applications";
                  #               };
                  #               "01.02" = {
                  #                 name = "Desktop";
                  #                 target = "/home/test/Desktop";
                  #               };
                  #               "01.03" = {
                  #                 name = "Documents";
                  #                 target = "/home/test/Documents";
                  #               };
                  #               "01.04" = {
                  #                 name = "Downloads";
                  #                 target = "/home/test/Downloads";
                  #               };
                  #               "01.05" = {
                  #                 name = "Movies";
                  #                 target = "/home/test/Movies";
                  #               };
                  #               "01.06" = {
                  #                 name = "Music";
                  #                 target = "/home/test/Music";
                  #               };
                  #               "01.07" = {
                  #                 name = "Pictures";
                  #                 target = "/home/test/Pictures";
                  #               };
                  #               "01.08" = {
                  #                 name = "Public";
                  #                 target = "/home/test/Public";
                  #               };
                  #               "01.09" = {
                  #                 name = "Templates";
                  #                 target = "/home/test/Templates";
                  #               };
                  #             };
                  #           };
                  #           "02" = {
                  #             name = "[Cloud]";
                  #             items = {
                  #               "02.01" = {
                  #                 name = "Dropbox";
                  #               };
                  #               "02.02" = {
                  #                 name = "Google Drive";
                  #               };
                  #             };
                  #           };
                  #         };
                  #       };

                  #       # Projects - Short-term efforts in your work or life that you're working on now.
                  #       "10-19" = {
                  #         name = "_Projects_";
                  #         categories = {
                  #           "11" = {
                  #             name = "[Maintaining]";
                  #             items = {
                  #               "11.01" = {
                  #                 name = "Johnny-Mnemonix";
                  #                 url = "https://github.com/lessuselesss/johnny-mnemonix";
                  #                 ref = "main";
                  #                 sparse = [
                  #                   "/examples/*"
                  #                 ];
                  #               };
                  #               "11.02" = {
                  #                 name = "Forks";
                  #               };
                  #             };
                  #           };
                  #           "12" = {
                  #             name = "[Pending]";
                  #             items = {
                  #               "12.01" = {
                  #                 name = "Waiting";
                  #               };
                  #               "12.02" = {
                  #                 name = "In Review";
                  #               };
                  #             };
                  #           };
                  #         };
                  #       };

                  #       # Areas - Long-term responsibilities you want to manage over time.
                  #       "20-29" = {
                  #         name = "_Areas_";
                  #         categories = {
                  #           "21" = {
                  #             name = "[Personal]";
                  #             items = {
                  #               "21.01" = {
                  #                 name = "Health";
                  #               };
                  #               "21.02" = {
                  #                 name = "Finance";
                  #               };
                  #               "21.03" = {
                  #                 name = "Family";
                  #               };
                  #             };
                  #           };
                  #           "22" = {
                  #             name = "[Professional]";
                  #             items = {
                  #               "22.01" = {
                  #                 name = "Career";
                  #               };
                  #               "22.02" = {
                  #                 name = "Skills";
                  #               };
                  #             };
                  #           };
                  #         };
                  #       };

                  #       # Topics or interests that may be useful in the future.
                  #       "30-39" = {
                  #         name = "_Resources_";
                  #         categories = {
                  #           "31" = {
                  #             name = "[References]";
                  #             items = {
                  #               "31.01" = {
                  #                 name = "Technical";
                  #               };
                  #               "31.02" = {
                  #                 name = "Academic";
                  #               };
                  #             };
                  #           };
                  #           "32" = {
                  #             name = "[Collections]";
                  #             items = {
                  #               "32.01" = {
                  #                 name = "Templates";
                  #               };
                  #               "32.02" = {
                  #                 name = "Checklists";
                  #               };
                  #             };
                  #           };
                  #         };
                  #       };

                  #       # Archive - Completed projects, references, and other resources that you no longer need to manage actively.
                  #       "90-99" = {
                  #         name = "_Archive_";
                  #         categories = {
                  #           "90" = {
                  #             name = "[Completed]";
                  #             items = {
                  #               "90.01" = {
                  #                 name = "Projects";
                  #               };
                  #               "90.02" = {
                  #                 name = "References";
                  #               };
                  #             };
                  #           };
                  #           "91" = {
                  #             name = "[Deprecated]";
                  #             items = {
                  #               "91.01" = {
                  #                 name = "Old Documents";
                  #               };
                  #               "91.02" = {
                  #                 name = "Legacy Files";
                  #               };
                  #             };
                  #           };
                  #         };
                  #       };
                  #     };
                  #   };
                };
              };
            }
            ./hosts/nixos
          ];
        }
    );

    nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
      modules = [./hosts/nix-on-droid/default.nix];
      pkgs = nixpkgs.legacyPackages.aarch64-linux;
      extraSpecialArgs = {
        inherit inputs;
      };
    };
  };
}
