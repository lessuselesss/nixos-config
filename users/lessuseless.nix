{pkgs, ...}: {
  home.packages = with pkgs; [
    # Development tools
    alacritty
    bun
    cargo
    cmake
    deno
    devenv
    docker
    docker-compose
    emacs-all-the-icons-fonts
    fabric-ai
    fd
    font-awesome
    hack-font
    jetbrains-mono
    lazydocker
    meslo-lgs-nf
    micromamba
    nix-direnv
    nodejs_23
    noto-fonts
    noto-fonts-emoji
    nurl
    pkg-config
    python312
    ripgrep
    sqlite
    tmux
    tree
    uv
    wget
    zip

    # Security tools
    age
    age-plugin-yubikey
    gnupg
    libfido2
    pass

    # Shell utilities
    bat
    btop
    fzf
    zsh-autosuggestions
    zsh-syntax-highlighting
  ];

  home.stateVersion = "24.11";

  programs = {
    # Import shared configurations
    alacritty.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    git = {
      enable = true;
      userName = "Ashley Barr";
      userEmail = "lessuseless@duck.com";
      lfs.enable = true;
      extraConfig = {
        init.defaultBranch = "main";
        core = {
          editor = "vim";
          autocrlf = "input";
        };
        commit.gpgsign = true;
        pull.rebase = true;
        rebase.autoStash = true;
      };
    };

    # Shell configuration
    zsh = {
      enable = true;
      autocd = false;
      enableCompletion = true;
      cdpath = ["~/.local/share/src"];

      plugins = [
        {
          name = "zsh-autosuggestions";
          src = pkgs.zsh-autosuggestions;
          file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
        }
        {
          name = "zsh-syntax-highlighting";
          src = pkgs.zsh-syntax-highlighting;
          file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
        }
      ];

      initExtraFirst = ''
        if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
          . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
          . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
        fi

        # Set the SSH_AUTH_SOCK environment variable
        export SSH_AUTH_SOCK=/Users/lessuseless/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh

        # Auto-suggestion configuration
        ZSH_AUTOSUGGEST_STRATEGY=(history completion)
        ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
        ZSH_AUTOSUGGEST_USE_ASYNC=1
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#808080"

        # Load fzf
        if [ -n "''${commands[fzf-share]}" ]; then
          source "$(fzf-share)/key-bindings.zsh"
          source "$(fzf-share)/completion.zsh"
        fi

        # Define variables for directories
        export PATH=$HOME/.pnpm-packages/bin:$HOME/.pnpm-packages:$PATH
        export PATH=$HOME/.npm-packages/bin:$HOME/bin:$PATH
        export PATH=$HOME/.local/share/bin:$PATH

        # Remove history data we don't want to see
        export HISTIGNORE="pwd:ls:cd"

        # Emacs is my editor
        export ALTERNATE_EDITOR=""
        export EDITOR="emacsclient -t"
        export VISUAL="emacsclient -c -a emacs"

        # Aliases
        alias e='emacsclient -t'
        alias pn=pnpm
        alias px=pnpx
        alias diff=difft
        alias ls='ls --color=auto'
        alias search='rg -p --glob "!node_modules/*"'
      '';
    };

    tmux = {
      enable = true;
      plugins = with pkgs.tmuxPlugins; [
        vim-tmux-navigator
        sensible
        yank
        prefix-highlight
        {
          plugin = power-theme;
          extraConfig = ''
            set -g @tmux_power_theme 'gold'
          '';
        }
        {
          plugin = resurrect;
          extraConfig = ''
            set -g @resurrect-dir '$HOME/.cache/tmux/resurrect'
            set -g @resurrect-capture-pane-contents 'on'
            set -g @resurrect-pane-contents-area 'visible'
          '';
        }
        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '5'
          '';
        }
      ];
      terminal = "screen-256color";
      prefix = "C-x";
      escapeTime = 10;
      historyLimit = 50000;
      extraConfig = ''
        set -g focus-events on
        set -g mouse on

        # Unbind default keys
        unbind C-b
        unbind '"'
        unbind %

        # Split panes
        bind-key x split-window -v
        bind-key v split-window -h

        # Move around panes with vim-like bindings
        bind-key -n M-k select-pane -U
        bind-key -n M-h select-pane -L
        bind-key -n M-j select-pane -D
        bind-key -n M-l select-pane -R
      '';
    };
  };
}
