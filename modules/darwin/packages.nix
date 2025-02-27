{pkgs}:
with pkgs; [
  dockutil
  gh
  pinentry_mac
  yabai
  mods
  mas
  iina
  alejandra

  # trezor-agent
  # ledger-agent
  # python312Packages.ledgerwallet
  # python312Packages.bleak
  # heimdall
  # heimdall-gui

  # Make sure SSH agent socket directory exists
  (pkgs.writeScriptBin "setup-ledger-ssh" ''
      #!${pkgs.stdenv.shell}
      mkdir -p ~/.ssh
      touch ~/.ssh/config
      if ! grep -q "IdentityAgent.*ledger-agent.sock" ~/.ssh/config; then
        echo "Host *
    PreferredAuthentications publickey
    IdentityAgent ~/.ssh/ledger-agent.sock" >> ~/.ssh/config
      fi
  '')
]
