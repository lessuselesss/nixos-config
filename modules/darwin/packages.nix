{pkgs}:
with pkgs; let
  shared-packages = import ../shared/packages.nix {inherit pkgs;};
in
  shared-packages
  ++ [
    dockutil
    gh
    pinentry_mac
    # yabai
    mods
    mas
    iina
    alejandra
    # heimdall
    # heimdall-gui
  ]
