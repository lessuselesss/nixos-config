{ pkgs, config, ... }:

# let
#   githubPublicKey = "ssh-ed25519 ...";
#   githubPublicSigningKey = ''
#     -----BEGIN PGP PUBLIC KEY BLOCK-----

#     ...
#     -----END PGP PUBLIC KEY BLOCK-----
#   '';
# in

{

  # ".ssh/id_github.pub" = {
  #   text = githubPublicKey;
  # };

  # ".ssh/pgp_github.pub" = {
  #   text = githubPublicSigningKey;
  # };

  # Initializes Emacs with org-mode so we can tangle the main config
  ".emacs.d/init.el" = {
    text = builtins.readFile ../shared/config/emacs/init.el;
  };
  
  # Initialize Karabiner-Elements
  ".config/karabiner/karabiner.json" = {
    text = builtins.readFile ../darwin/config/karabiner/karabiner.json;
  };

  ".config/karabiner/assets/complex_modifications/karabiner.json" = {
    text = builtins.readFile ../darwin/config/karabiner/assets/complex_modifications/karabiner.json;
  };
}
