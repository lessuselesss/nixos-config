{ config, pkgs, lib, home-manager, ... }:

let
  user = "lessuseless";
  # Define the content of your file as a derivation
  myEmacsLauncher = pkgs.writeScript "emacs-launcher.command" ''
    #!/bin/sh
    emacsclient -c -n &
  '';
  sharedFiles = import ../shared/files.nix { inherit config pkgs; };
  additionalFiles = import ./files.nix { inherit user config pkgs; };
in
{
  imports = [
   ./dock
  ];

  ########################
  #   Single User Setup  #
  #  #####################
  #  
  #  # First, set up the admin user
  #  users.users.admin = {
  #    name = "admin";
  #    home = "/Users/admin";
  #    shell = pkgs.zsh;  # or pkgs.bashInteractive if you prefer
  #  
  ########################

  # Then set up your standard user
  users.users.${user} = { 
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  # Configure home-manager for both users
  home-manager = {
    useGlobalPkgs = true;
    users.admin = { pkgs, config, lib, ... }: {
      home = {
        enableNixpkgsReleaseCheck = false;
        packages = pkgs.callPackage ./packages.nix {};
        stateVersion = "24.05";
      };
      programs = {} // import ../shared/home-manager.nix { inherit config pkgs lib; };
      manual.manpages.enable = false;
    };
    
    users.${user} = { pkgs, config, lib, ... }: {
      home = {
        enableNixpkgsReleaseCheck = false;
        packages = pkgs.callPackage ./packages.nix {};
        file = lib.mkMerge [
          sharedFiles
          additionalFiles
          { "emacs-launcher.command".source = myEmacsLauncher; }
        ];
        stateVersion = "24.05";
      };
      programs = {} // import ../shared/home-manager.nix { inherit config pkgs lib; };
      manual.manpages.enable = false;
    };
  };

  # Configure Nix settings to allow admin user to manage the system
  nix = {
    settings = {
      trusted-users = [ "@admin" "root" ];  # Give admin group Nix management capabilities
      # ... other nix settings ...
    };
    # ... rest of nix configuration ...
  };

  homebrew = {
    enable = true;
    casks = pkgs.callPackage ./casks.nix {};
    # onActivation.cleanup = "uninstall";

    masApps = {
      #"1password" = 1333542190;
      #"wireguard" = 1451685025;
    };
  };

  # Fully declarative dock using the latest from Nix Store
  local = { 
    dock = {
      entries = [
        { path = "/Applications/Slack.app/"; }
        { path = "/System/Applications/Messages.app/"; }
        { path = "/System/Applications/Facetime.app/"; }
        { path = "${pkgs.alacritty}/Applications/Alacritty.app/"; }
        { path = "/System/Applications/Music.app/"; }
        { path = "/System/Applications/News.app/"; }
        { path = "/System/Applications/Photos.app/"; }
        { path = "/System/Applications/Photo Booth.app/"; }
        { path = "/System/Applications/TV.app/"; }
        { path = "/System/Applications/Home.app/"; }
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
  };
}
