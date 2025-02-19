{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  inherit (pkgs) stdenv;
in {
  config = mkMerge [
    # Common font packages for both systems
    {
      fonts.packages = with pkgs; [
        dejavu_fonts
        emacs-all-the-icons-fonts
        jetbrains-mono
        font-awesome
        noto-fonts
        noto-fonts-emoji
        feather-font # from overlay
      ];
    }

    # NixOS specific configuration
    (mkIf stdenv.isLinux {
      fonts = {
        # Removed fontDir.enable as it no longer has any effect
      };
    })

    # Darwin specific configuration
    (mkIf stdenv.isDarwin {
      fonts = {
        # On Darwin, fonts.packages are automatically enabled
      };
    })
  ];
}
