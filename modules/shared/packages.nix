{ pkgs }:

with pkgs; [
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
  coreutils
  killall
  neofetch
  openssh
  sqlite
  wget
  zip
  direnv

  # Encryption and security tools
  age
  age-plugin-yubikey
  gnupg
  libfido2

  # Cloud-related tools and SDKs
  docker
  docker-compose

  # Media-related packages
  emacs-all-the-icons-fonts
  dejavu_fonts
  ffmpeg
  fd
  font-awesome
  hack-font
  noto-fonts
  noto-fonts-emoji
  meslo-lgs-nf

  # Node.js development tools
  nodePackages.npm # globally install npm
  nodePackages.prettier
  nodejs

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

  # Python packages 
  # USE DEVENV 
  #python312
  #python313Packages.virtualenv # globally install virtualenv
  (python313.withPackages (ps: with ps; [
      time-machine
      virtualenv
      #pyobjc
      #mlx
      pip
      # other Python packages...
    ]))

    devenv
##############################################################
#   !!!! Use Devenv for project specific python shells !!!! ##
#  ###########################################################
#  # devenv.nix
#  { pkgs, lib, config, inputs, ... }:
#
#  {
#    languages.python = {
#      enable = true;
#      venv.enable = true;
#      venv.requirements = ''
#        pyside2
#      '';
#  };
#
#  enterShell = ''
#    python -c "import PySide2" && echo "No errors!"
#  '';
#  }
##############################################################
]
