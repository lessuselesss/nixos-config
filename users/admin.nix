{pkgs, ...}: {
  home = {
    # Basic admin packages
    packages = with pkgs; [
      # System monitoring and management
      htop
      btop
      iftop
      tree
      wget
      curl
      ripgrep
      fd
      jq

      # Security tools
      gnupg
      age
      age-plugin-yubikey
      pass

      # Basic development tools
      git
    ];

    stateVersion = "24.11";
  };

  # Basic shell configuration for admin
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      initExtra = ''
        # Admin-specific shell configuration
        export EDITOR="vim"

        # Useful aliases for system administration
        alias ll='ls -la'
        alias df='df -h'
        alias du='du -h'
        alias free='free -m'
        alias top='htop'

        # Homebrew sudo wrapper
        brew() {
          if [[ $1 == "install" || $1 == "uninstall" || $1 == "upgrade" ]]; then
            echo "Running Homebrew with sudo..."
            sudo /opt/homebrew/bin/brew "$@"
          else
            /opt/homebrew/bin/brew "$@"
          fi
        }
      '';
    };

    # Git configuration
    git = {
      enable = true;
      userName = "Admin User";
      userEmail = "admin@localhost";
      extraConfig = {
        init.defaultBranch = "main";
        core = {
          editor = "vim";
          autocrlf = "input";
        };
      };
    };

    # Basic vim configuration
    vim = {
      enable = true;
      extraConfig = ''
        set number
        set relativenumber
        set expandtab
        set tabstop=2
        set shiftwidth=2
        syntax on
      '';
    };
  };
}
