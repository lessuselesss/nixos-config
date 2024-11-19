{ agenix, config, pkgs, ... }:

let user = "lessuseless"; in

{

  imports = [
    ../../modules/darwin/home-manager.nix
    # ../../../modules/darwin/config/sketchybar.nix
    # ../../modules/darwin/config/karabiner/karabiner.nix
    ../../modules/darwin/secrets.nix
    ../../modules/shared
    # ./nextdns.nix
    agenix.darwinModules.default
  ];

  # Auto upgrade nix package and the daemon service.
services = {
    nix-daemon.enable = true;
    yabai = {
      enable = true;
      };
 
    sketchybar = {
      enable = true;
      extraPackages = with pkgs; [
        jankyborders
        nushell
      ];
    };
    
    jankyborders = {
      enable = true;
      blur_radius = 5.0;
      hidpi = true;
      active_color = "0xFFFF69B4";
      # active_color = "0xAAB279A7";
      # background_color = "0xAAB279A7";
      inactive_color = "0x33867A74";
      # width = "5.0";
    };

    tailscale = {
      enable = true; # false = Using App Store application
      overrideLocalDns = true;
    };
  };

  # Setup user, packages, programs
  nix = {
    package = pkgs.nix;
    settings = {
      trusted-users = [ "@admin" "${user}" ];
      substituters = [ "lessuseless.cachix.org" "https://nix-community.cachix.org" "https://cache.nixos.org"  ];
      trusted-public-keys = [ 
        "lessuselesss.cachix.org-1:nwRzA1J+Ze2nJAcioAfp77ifk8sncUi963WW2RExOwA="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        ];
    };

    gc = {
      user = "root";
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 30d";
    };

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Turn off NIX_PATH warnings now that we're using flakes
  system.checks.verifyNixPath = false;

  # Load configuration that is shared across systems
  environment.systemPackages = with pkgs; [
    emacs-unstable
    agenix.packages."${pkgs.system}".default
  ] ++ (import ../../modules/shared/packages.nix { inherit pkgs; });

  launchd.user.agents.emacs.path = [ config.environment.systemPath ];
  launchd.user.agents.emacs.serviceConfig = {
    KeepAlive = true;
    ProgramArguments = [
      "/bin/sh"
      "-c"
      "/bin/wait4path ${pkgs.emacs}/bin/emacs && exec ${pkgs.emacs}/bin/emacs --fg-daemon"
    ];
    StandardErrorPath = "/tmp/emacs.err.log";
    StandardOutPath = "/tmp/emacs.out.log";
  };

  system = {
    stateVersion = 4;

    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;

        # Enable press-and-hold repeating
        ApplePressAndHoldEnabled = false;

        # 120, 90, 60, 30, 12, 6, 2
        KeyRepeat = 2;

        # 120, 94, 68, 35, 25, 15
        InitialKeyRepeat = 15;

        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;
        
        # Auto hide the menubar
        _HIHideMenuBar = true;

        # Enable full keyboard access for all controls
        #AppleKeyboardUIMode = 3;

        # Disable "Natural" scrolling
        "com.apple.swipescrolldirection" = false;

        # Disable smart dash/period/quote substitutions
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;

        # Disable automatic capitalization
        NSAutomaticCapitalizationEnabled = false;

        # Using expanded "save panel" by default
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;

        # Increase window resize speed for Cocoa applications
        NSWindowResizeTime = 0.001;

        # Save to disk (not to iCloud) by default
        NSDocumentSaveNewDocumentsToCloud = true;
      };

      dock = {

        # Set icon size, dock orientation and launch animation
        launchanim = true;
        tilesize = 48;
        orientation = "left";

        # Set dock to auto-hide, and transparentize icons of hidden apps (⌘H)
        autohide = true;
        showhidden = true;

        # Disable to show recents, and light-dot of running apps
        show-recents = false;
        show-process-indicators = false;
      };

      finder = {

        _FXShowPosixPathInTitle = false;

        # Allow quitting via ⌘Q
        QuitMenuItem = true;

        # Disable warning when changing a file extension
        FXEnableExtensionChangeWarning = false;

        # Show all files and their extensions
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;

        # Show path bar, and layout as multi-column
        ShowPathbar = true;
        FXPreferredViewStyle = "clmv";

        # Search in current folder by default
        FXDefaultSearchScope = "SCcf";
      };

      trackpad = {
        # Enable trackpad tap to click
        Clicking = true;

        # Enable 3-finger drag
        TrackpadThreeFingerDrag = true;
      };

      ActivityMonitor = {
        # Sort by CPU usage
        SortColumn = "CPUUsage";
        SortDirection = 0;
      };

      LaunchServices = {
        # Disable quarantine for downloaded apps
        LSQuarantine = false;
      };

      CustomSystemPreferences = {
        NSGlobalDomain = {
          # Set the system accent color, TODO: https://github.com/LnL7/nix-darwin/pull/230
          AppleAccentColor = 6;
          # Jump to the spot that's clicked on the scroll bar, TODO: https://github.com/LnL7/nix-darwin/pull/672
          AppleScrollerPagingBehavior = true;
          # Prefer tabs when opening documents, TODO: https://github.com/LnL7/nix-darwin/pull/673
          AppleWindowTabbingMode = "always";
        };
        "com.apple.finder" = {
          # Keep the desktop clean
          ShowHardDrivesOnDesktop = false;
          ShowRemovableMediaOnDesktop = false;
          ShowExternalHardDrivesOnDesktop = false;
          ShowMountedServersOnDesktop = false;

          # Show directories first
          _FXSortFoldersFirst = true; # TODO: https://github.com/LnL7/nix-darwin/pull/594

          # New window use the $HOME path
          NewWindowTarget = "PfHm";
          NewWindowTargetPath = "file://$HOME/";

          # Allow text selection in Quick Look
          QLEnableTextSelection = true;
        };
        "com.apple.Safari" = {
          # For better privacy
          UniversalSearchEnabled = false;
          SuppressSearchSuggestions = true;
          SendDoNotTrackHTTPHeader = true;

          # Disable auto open safe downloads
          AutoOpenSafeDownloads = false;

          # Enable Develop Menu, Web Inspector
          IncludeDevelopMenu = true;
          IncludeInternalDebugMenu = true;
          WebKitDeveloperExtras = true;
          WebKitDeveloperExtrasEnabledPreferenceKey = true;
          "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" = true;
        };
        "com.apple.universalaccess" = {
          # Set the cursor size, TODO: https://github.com/LnL7/nix-darwin/pull/671
          mouseDriverCursorSize = 1.5;
          reduceMotion = false; # Fast Space Switching
        };
        "com.apple.screencapture" = {
          # Set the filename which screencaptures should be written, TODO: https://github.com/LnL7/nix-darwin/pull/670
          name = "screenshot";
          include-date = false;
        };
        "com.apple.desktopservices" = {
          # Avoid creating .DS_Store files on USB or network volumes
          DSDontWriteUSBStores = true;
          DSDontWriteNetworkStores = true;
        };
        "com.apple.frameworks.diskimages" = {
          # Disable disk image verification
          skip-verify = true;
          skip-verify-locked = true;
          skip-verify-remote = true;
        };
        "com.apple.CrashReporter" = {
          # Disable crash reporter
          DialogType = "none";
        };
        "com.apple.AdLib" = {
          # Disable personalized advertising
          forceLimitAdTracking = true;
          allowApplePersonalizedAdvertising = false;
          allowIdentifierForAdvertising = false;
        };
      };
    };
  };
}