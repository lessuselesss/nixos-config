# /rootdir/modules/shared/johnny-mnemonix.nix
# NOTE: The johnny-mnemonix configuration structure is critical for proper syntax.
# Errors in the structure (missing braces, incorrect nesting) can cause cryptic
# error messages in seemingly unrelated parts of the configuration (like module imports).
# If you encounter syntax errors about missing semicolons or INHERIT statements,
# check this configuration first.
{
  config,
  lib,
  ...
}: let
  user = "lessuseless"; # This should match the user defined in flake.nix
in {
  options.johnny-mnemonix = {
    enable = lib.mkEnableOption "Johnny Mnemonix configuration";
    baseDir = lib.mkOption {
      type = lib.types.str;
      default = "/Users/${user}/Documents";
      description = "Base directory for Johnny Mnemonix";
    };
    spacer = lib.mkOption {
      type = lib.types.str;
      default = "_";
      description = "Spacer character for directory names";
    };
    areas = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Areas configuration for Johnny Mnemonix";
    };
  };

  config = lib.mkIf config.johnny-mnemonix.enable {
    # Johnny Mnemonix specific configuration
    johnny-mnemonix = {
      areas = {
        "00-09" = {
          name = "System";
          categories = {
            "00" = {
              name = "Meta";
              items = {
                "00.00" = {
                  name = "nixos-config";
                  url = "https://github.com/lessuselesss/nixos-config";
                  ref = "main";
                };
                "00.01" = {
                  name = "logs";
                  target = "/var/log";
                };
                "00.02" = {
                  name = "qubesOS-config";
                  url = "https://github.com/lessuselesss/qubesos-config";
                  ref = "main";
                };
                "00.03" = {
                  name = "workflows";
                };
                "00.04" = {
                  name = "VMs";
                };
              };
            };
            "01" = {
              name = "home";
              items = {
                "01.00" = {
                  name = "dotfiles";
                  target = "/Users/${user}/.dotfiles";
                };
                "01.01" = {
                  name = "applications";
                  target = "/Users/${user}/Applications";
                };
                "01.02" = {
                  name = "desktop";
                  target = "/Users/${user}/Desktop";
                };
                "01.03" = {
                  name = "documents";
                  target = "/Users/${user}/Documents";
                };
                "01.04" = {
                  name = "downloads";
                  target = "/Users/${user}/.local/share/downloads";
                };
                "01.05" = {
                  name = "movies";
                  target = "/Users/${user}/Movies";
                };
                "01.06" = {
                  name = "music";
                  target = "/Users/${user}/Music";
                };
                "01.07" = {
                  name = "pictures";
                  target = "/Users/${user}/Pictures";
                };
                "01.08" = {
                  name = "public";
                  target = "/Users/${user}/Public";
                };
                "01.09" = {
                  name = "templates";
                  target = "/Users/${user}/Templates";
                };
                "01.10" = {
                  name = "dotlocal_share";
                  target = "/Users/${user}/.local/share";
                };
                "01.11" = {
                  name = "dotlocal_bin";
                  target = "/Users/${user}/.local/bin";
                };
                "01.12" = {
                  name = "dotlocal_lib";
                  target = "/Users/${user}/.local/lib";
                };
                "01.13" = {
                  name = "dotlocal_include";
                  target = "/Users/${user}/.local/include";
                };
                "01.14" = {
                  name = "dotlocal_state";
                  target = "/Users/${user}/.local/state";
                };
                "01.15" = {
                  name = "dotlocal_cache";
                  target = "/Users/${user}/.cache";
                };
              };
            };
            "02" = {
              name = "Cloud";
              items = {
                "02.00" = {
                  name = "configs";
                  target = "/Users/${user}/.config/rclone";
                };
                "02.01" = {name = "dropbox";};
                "02.02" = {name = "google drive";};
                "02.03" = {
                  name = "icloud";
                  target = "/Users/${user}/Library/Mobile Documents/com~apple~CloudDocs";
                };
              };
            };
          };
        };
        "10-19" = {
          name = "Projects";
          categories = {
            "11" = {
              name = "maintaining";
              items = {
                "11.01" = {
                  name = "johnny-Mnemonix";
                  url = "https://github.com/lessuselesss/johnny-mnemonix";
                  ref = "main";
                };
                "11.02" = {name = "forks";};
                "11.03" = {
                  name = "anki Sociology";
                  url = "https://github.com/lessuselesss/anki_sociology100";
                  ref = "main";
                };
                "11.04" = {
                  name = "anki Ori's Decks";
                  url = "https://github.com/lessuselesss/anki-ori_decks";
                  ref = "main";
                };
                "11.05" = {
                  name = "claude desktop";
                  url = "https://github.com/lessuselesss/claude_desktop";
                  ref = "main";
                };
                "11.06" = {
                  name = "dygma raise - Miryoku";
                  url = "https://github.com/lessuselesss/dygma-raise-miryoku";
                  ref = "main";
                };
                "11.07" = {
                  name = "uber-FZ_SD-files";
                  url = "https://github.com/lessuselesss/Uber-FZ_SD-Files";
                  ref = "main";
                };
                "11.08" = {
                  name = "prosocial_ide";
                  url = "https://github.com/lessuselesss/Prosocial_IDE";
                  ref = "main";
                };
              };
            };
            "12" = {
              name = "Contributing";
              items = {
                "12.01" = {
                  name = "screenpipe";
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
                  name = "fabric";
                  url = "https://github.com/lessuselesss/fabric";
                  ref = "main";
                };
                "12.07" = {
                  name = "whisper diarization";
                  url = "https://github.com/lessuselesss/whisper-diarization";
                  ref = "main";
                };
              };
            };
            "13" = {
              name = "Testing_ai";
              items = {
                "13.01" = {
                  name = "curxy";
                  url = "https://github.com/ryoppippi/curxy";
                  ref = "main";
                };
                "13.02" = {
                  name = "dify";
                  url = "https://github.com/langgenius/dify";
                  ref = "main";
                };
                "13.03" = {
                  name = "browser-use";
                  url = "https://github.com/browser-use/browser-use";
                  ref = "main";
                };
                "13.04" = {
                  name = "omniParser";
                  url = "https://github.com/microsoft/OmniParser";
                  ref = "main";
                };
              };
            };
            "14" = {
              name = "Pending";
              items = {
                "14.01" = {name = "waiting";};
              };
            };
          };
        };
        "20-29" = {
          name = "Areas";
          categories = {
            "21" = {
              name = "Personal";
              items = {
                "21.01" = {name = "health";};
                "21.02" = {name = "finance";};
                "21.03" = {name = "family";};
              };
            };
            "22" = {
              name = "Professional";
              items = {
                "22.01" = {
                  name = "career";
                  url = "https://github.com/lessuselesss/careerz";
                };
                "22.02" = {name = "skills";};
              };
            };
          };
        };
        "30-39" = {
          name = "Resources";
          categories = {
            "30" = {
              name = "devenv_repos";
              items = {
                "30.01" = {
                  name = "rwkv-Runner";
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
              name = "References";
              items = {
                "31.01" = {name = "technical";};
                "31.02" = {name = "academic";};
              };
            };
            "32" = {
              name = "Collections";
              items = {
                "32.01" = {name = "templates";};
                "32.02" = {name = "checklists";};
              };
            };
          };
        };
        "90-99" = {
          name = "Archive";
          categories = {
            "90" = {
              name = "Completed";
              items = {
                "90.01" = {name = "projects";};
                "90.02" = {name = "references";};
              };
            };
            "91" = {
              name = "deprecated";
              items = {
                "91.01" = {name = "old Documents";};
                "91.02" = {name = "legacy Files";};
              };
            };
            "92" = {
              name = "Models";
              items = {
                "92.01" = {name = "huggingface";};
                "92.02" = {name = "ollama";};
              };
            };
            "93" = {
              name = "Datasets";
              items = {
                "93.01" = {name = "kaggle";};
                "93.02" = {name = "x";};
              };
            };
          };
        };
      };
    };
  };
}
