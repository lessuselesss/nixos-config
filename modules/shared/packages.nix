{pkgs, ...}: let
  packages = with pkgs; [
    # Automation
    fabric-ai
    #exo

    # General packages for development and system management
    alacritty
    aspell
    aspellDicts.en
    bash-completion
    bat
    btop

    pkg-config
    bun
    cmake
    cargo

    coreutils
    killall
    neofetch
    openssh
    sqlite
    wget
    zip
    nix-direnv
    devenv
    # warp-terminal
    nil

    # Encryption and security tools
    age
    age-plugin-yubikey
    gnupg
    libfido2
    pass

    # Cloud-related tools and SDKs
    docker
    docker-compose

    # Media-related packages
    emacs-all-the-icons-fonts
    emacsPackages.exec-path-from-shell
    dejavu_fonts
    ffmpeg
    fd
    font-awesome
    hack-font
    noto-fonts
    noto-fonts-emoji
    meslo-lgs-nf

    # Text and terminal utilities
    htop
    hunspell
    iftop
    jetbrains-mono
    jq
    ripgrep
    tree
    tmux
    unrar
    unzip
    zsh-powerlevel10k
    micromamba
    lazydocker
    aider-chat
    nurl
    uv

    # Python Development Tools
    (python312.withPackages (ps:
      with ps; [
        time-machine
        virtualenv
        pip
      ]))

    # Node.js Development Tools
    nodejs_23
  ];
in
  packages
