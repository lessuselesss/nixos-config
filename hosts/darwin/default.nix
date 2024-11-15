{ agenix, config, pkgs, ... }:

let user = "lessuseless"; in

{

  imports = [
    ../../modules/darwin/secrets.nix
    ../../modules/darwin/home-manager.nix
    ../../modules/shared
    # ./nextdns.nix
     agenix.darwinModules.default
  ];

  # Auto upgrade nix package and the daemon service.
services = {
    nix-daemon.enable = true;
    # nextdns = {
    #   enable = true;
    #   configId = "4f55c4"; # Replace with your NextDNS configuration ID
    # };
    yabai = {
      enable = true;
      config = {
        layout = "bsp";

        # external_bar = "off:40:0";
        # menubar_opacity = "1.0";
        # mouse_follows_focus = "off";
        # focus_follows_mouse = "off";
        # display_arrangement_order = [ "default" ];
        
        # insert_feedback_color = "0xffd75f5f";
        # split_ratio = 0.50;
        # split_type = "auto";
        # auto_balance = false;

        # # Window Spacing
        # top_padding = 12;
        # bottom_padding = 12;
        # left_padding = 12;
        # right_padding = 12;
        # window_gap = 6;

        # # Window Properties
        # window_origin_display = "default";
        # window_placement = "second_child";
        # window_zoom_persist = true;
        # window_shadow = true;
        # window_animation_duration = 0.0;
        # window_animation_easing = "ease_out_circ";
        # window_opacity_duration = 0.0;
        # active_window_opacity = 1.0;
        # normal_window_opacity = 0.90;
        # window_opacity = false;
        window_shadow = "float";
        window_gap = "10";
        
        # # Mouse Properties
        mouse_modifier = "ctrl"; 
        mouse_drop_action = "stack";     
        # mouse_action1 = "move";
        # mouse_action2 = "resize";
        # mouse_drop_action = "swap";
      };
      
      extraConfig = ''
        yabai -m signal --add event=display_added action="yabai -m rule --remove label=calendar && yabai -m rule --add app='Fantastical' label='calendar' display=east" active=yes
        yabai -m signal --add event=display_removed action="yabai -m rule --remove label=calendar && yabai -m rule --add app='Fantastical' label='calendar' native-fullscreen=on" active=yes
        yabai -m rule --add app='OBS' display=east
        yabai -m rule --add app='Spotify' display=east

        yabai -m rule --add app='Cardhop' manage=off
        yabai -m rule --add app='Pop' manage=off
        yabai -m rule --add app='System Settings' manage=off
        yabai -m rule --add app='Timery' manage=off
      '';
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
      substituters = [ "https://nix-community.cachix.org" "https://cache.nixos.org" ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
      # trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ] 
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

        # Enable press-and-hold repeating
        #ApplePressAndHoldEnabled = false;
        #InitialKeyRepeat = 10;
        #KeyRepeat = 1;

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