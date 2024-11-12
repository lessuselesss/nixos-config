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



  # # Define the "admin" user with root-like privileges
  users.users.admin = {
    isNormalUser = true;
    home = "/home/admin";
    extraGroups = [ "wheel" ]; # wheel group allows sudo access
    hashedPassword = "<hashed-password>"; # You can set a hashed password here or use `passwordFile` or `password` directly for simplicity
    shell = pkgs.bashInteractive; # You can specify any shell here
  };

  # # Define a less privileged user, "standard"
  # users.users.standard = {
  #   isNormalUser = true;
  #   home = "/home/standard";
  #   hashedPassword = "<hashed-password>";
  #   shell = pkgs.bashInteractive;
  # };
  # ... Itza meee!
  users.users.standard = { 
    name = "standard";
    home = "/Users/standard";
    hashedPassword = "$6$ewILqVwo85fq2Dtq$BXkOTy2hcBdgZ5gu7tOwd1Ns35oYHcUz/962YIF0FeDsbBTKQL8Xs73PAxMaF6nWHEJZVXhPKf.n/K7F.iGRx0";
    isHidden = false;
    shell = pkgs.bashInteractive; #pkgs.zsh;
  };

  # # Ensure sudo privileges for members of the "wheel" group
  # security.sudo = {
  #   enable = true;
  #   wheelNeedsPassword = true; # Members of the wheel group must provide a password for sudo
  # };

  # # Setup user packages, programs, and nix settings
  # nix = {
  #   package = pkgs.nix;
  #   configureBuildUsers = true;

  #   settings = {
  #     trusted-users = [ "@admin" "root" "standard" ];
  #     substituters = [ "https://nix-community.cachix.org" "https://cache.nixos.org" ];
  #     trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
  #   };

  #   gc = {
  #     user = "root";
  #     automatic = true;
  #     interval = { Weekday = 0; Hour = 2; Minute = 0; };
  #     options = "--delete-older-than 30d";
  #   };


  homebrew = {
    enable = true;
    casks = pkgs.callPackage ./casks.nix {};
    # onActivation.cleanup = "uninstall";
  };
  
    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    # If you have previously added these apps to your Mac App Store profile (but not installed them on this system),
    # you may receive an error message "Redownload Unavailable with This Apple ID".
    # This message is safe to ignore. (https://github.com/dustinlyons/nixos-config/issues/83)

    masApps = {
      #"1password" = 1333542190;
      #"wireguard" = 1451685025;
    };
  };

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    users.${user} = { pkgs, config, lib, ... }:{
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

      # Marked broken Oct 20, 2022 check later to remove this
      # https://github.com/nix-community/home-manager/issues/3344
      manual.manpages.enable = false;
    };
  };

  # Fully declarative dock using the latest from Nix Store
  local = { 
    dock = {
      #enable = true;
      #autohide = true;
      #orientation = "left";
      #show-process-indicators = false;
      #show-recents = false;
      #static-only = true;
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
