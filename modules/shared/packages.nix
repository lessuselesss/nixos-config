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
  devenv    

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

  # Python Developement Tools 

  (python313.withPackages (ps: with ps; [
      time-machine
      virtualenv
      #pyobjc
      #mlx
      pip
      # other Python packages...

      # USE DEVENV FOR PROJECT-SPECIFIC ENVS 
    ]))

  # Node.js Developement Tools
  # fzf
  # nodePackages.live-server
  # nodePackages.nodemon
  # nodePackages.prettier
  # nodePackages.npm
  # nodejs

# ...

# Python
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

# nodejs
##############################################################
#   !!!! Use Devenv for project specific node shells !!!!   ##
#  ###########################################################
#  # devenv.nix
#  { pkgs, lib, config, inputs, ... }:
#
#  {
#    languages.nodejs = {
#      enable = true;
#      version = "20";  # Specify Node.js version
#      package = pkgs.nodejs_20;
#      # Add global npm packages
#      packages = {
#        typescript = "latest";
#        "@types/node" = "latest";
#        eslint = "latest";
#        prettier = "latest";
#      };
#    };
#
#    enterShell = ''
#      node --version && npm --version && echo "Node.js environment ready!"
#    '';
#  }
##############################################################
]
