{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}: let
  user = "lessuseless";
  # Define the content of your file as a derivation
  myEmacsLauncher = pkgs.writeScript "emacs-launcher.command" ''
    #!/bin/sh
      emacsclient -c -n &
  '';
  sharedFiles = import ../shared/files.nix {inherit config pkgs;};
  additionalFiles = import ./files.nix {inherit user config pkgs;};
in {
  imports = [
    ./dock
  ];

  # It me
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  homebrew = {
    # This is a module from nix-darwin
    # Homebrew is *installed* via the flake input nix-homebrew
    enable = true;
    casks = pkgs.callPackage ./casks.nix {};

    # If shell gives compinit errors and completions
    # or shell elements are broken,
    # imparitively run:
    # `brew upgrade && brew cleanup && brew completions link`

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #:
masApps = {
    "Gordian Seed Tool" = 1545088229;
    "DuckDuckGo" = 663592361;  
    "Pure Paste" = 1611378436;  
    "Shareful" = 1522267256;  
    "Command X" = 6448461551;  
    "One Thing" = 1604176982; 
    "Folder Peek" = 1615988943; 
    "Seed Tool" = 1545088229; 
    # "Today" = 6443714928;  
    "Refined GitHub" = 1519867270;  
    };
  };

#  networking.knownNetworkServices = [
#    "Wi-Fi"
#    "USB 10/100/1000 LAN"
#    "Bluetooth PAN"
#     "Thunderbolt Bridge"
#  ];

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    users.${user} = {
      pkgs,
      config,
      lib,
      ...
    }: {
      home = {
        enableNixpkgsReleaseCheck = false;
        packages = pkgs.callPackage ./packages.nix {};
        file = lib.mkMerge [
          sharedFiles
          additionalFiles
          {
            "emacs-launcher.command".source = myEmacsLauncher;
          }
          # Comment out the previous implementation
          # (let
          #   mkNumberedDirs = {
          #     basePath,
          #     prefix ? "",
          #     padWidth ? 2,
          #     start ? 0,
          #     end ? 90,
          #     step ? 10,
          #   }: let
          #     ... previous implementation ...
          #   };
          # in
          #   mkNumberedDirs {
          #     basePath = ".local/share/documents";
          #     prefix = "Area";
          #     start = 0;
          #     end = 90;
          #     step = 10;
          #   })
        ];

        stateVersion = "24.11";
      };

      programs = {} // import ../shared/home-manager.nix {inherit config pkgs lib;};

      # Marked broken Oct 20, 2022 check later to remove this
      # https://github.com/nix-community/home-manager/issues/3344
      manual.manpages.enable = false;
    };
  };

  # Fully declarative dock using the latest from Nix Store
  local = {
    dock.enable = true;
    dock.entries = [
      # { path = "${pkgs.warp}/Applications/Warp.app/"; }
      # { path = "/System/Applications/Facetime.app/"; }
      {path = "${pkgs.alacritty}/Applications/Alacritty.app/";}
      {path = "${pkgs.emacs}/Applications/Emacs.app/";}

      #{ path = "/Applications/Slack.app/"; }
      #{ path = "/System/Applications/Messages.app/"; }
      #{ path = "/System/Applications/Facetime.app/"; }
      #{ path = "/Applications/Telegram.app/"; }
      #{ path = "${pkgs.alacritty}/Applications/Alacritty.app/"; }
      #{ path = "/System/Applications/Music.app/"; }
      #{ path = "/System/Applications/News.app/"; }
      #{ path = "/System/Applications/Photos.app/"; }
      #{ path = "/System/Applications/Photo Booth.app/"; }
      #{ path = "/System/Applications/TV.app/"; }
      #{ path = "${pkgs.jetbrains.phpstorm}/Applications/PhpStorm.app/"; }
      #{ path = "/Applications/TablePlus.app/"; }
      #{ path = "/Applications/Asana.app/"; }
      #{ path = "/Applications/Drafts.app/"; }
      #{ path = "/System/Applications/Home.app/"; }
      {path = "/Applications/iPhone Mirroring.app/";}
      {
        path = toString myEmacsLauncher;
        section = "others";
      }
      {
        path = "${config.users.users.${user}.home}/.local/share/";
        section = "others";
        options = "--sort name --view grid --display folder";
      }
      {
        path = "${config.users.users.${user}.home}/.local/share/downloads";
        section = "others";
        options = "--sort name --view grid --display stack";
      }
    ];
  };
}
