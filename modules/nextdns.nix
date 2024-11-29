# hosts/darwin/nextdns.nix
{
  config,
  pkgs,
  lib,
  ...
}: {
  options.services.nextdns = {
    enable = lib.mkEnableOption "NextDNS profile installation";
    configId = lib.mkOption {
      type = lib.types.str;
      description = "NextDNS configuration ID";
      example = "abcdef";
    };
  };

  config = lib.mkIf config.services.nextdns.enable {
    system.activationScripts.extraActivation.text = lib.mkAfter ''
      # NextDNS Profile Installation
      echo "Checking NextDNS profile..."

      NEXTDNS_CONFIG_ID="${config.services.nextdns.configId}"
      PROFILE_NAME="NextDNS_$NEXTDNS_CONFIG_ID"

      # Check if profile is already installed
      if ! /usr/bin/profiles -L | grep -q "$PROFILE_NAME"; then
        echo "Installing NextDNS profile..."
        PROFILE_URL="https://apple.nextdns.io/$NEXTDNS_CONFIG_ID/profile"

        # Create a temporary directory for the profile
        TEMP_DIR=$(mktemp -d)
        PROFILE_PATH="$TEMP_DIR/nextdns_profile.mobileconfig"

        # Download the profile
        ${pkgs.curl}/bin/curl -sL "$PROFILE_URL" -o "$PROFILE_PATH"

        # Install the profile
        echo "Opening NextDNS profile for installation..."
        open "$PROFILE_PATH"

        echo "Please complete the NextDNS profile installation in System Settings."
        echo "You may need to approve the profile in System Settings > Privacy & Security."
      else
        echo "NextDNS profile is already installed."
      fi
    '';

    # Optional: Install nextdns CLI tool
    environment.systemPackages = with pkgs; [
      nextdns
    ];
  };
}
