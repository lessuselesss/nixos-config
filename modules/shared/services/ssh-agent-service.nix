{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    services.ledger-ssh-agent = {
      enable = lib.mkEnableOption "Enable ledger SSH agent service";
      package = lib.mkPackageOption pkgs "openssh" {};
      socketPath = lib.mkOption {
        type = lib.types.str;
        default = "/tmp/ledger-ssh-agent.sock";
        description = "The SSH agent socket path";
      };
    };
  };
  config = let
    cfg = config.services.ledger-ssh-agent;
  in
    lib.mkIf cfg.enable {
      settings.processes.ledger-ssh-agent = {
        command = "${lib.getExe cfg.package} -D -a ${cfg.socketPath}";
        environment = {
          SSH_AUTH_SOCK = cfg.socketPath;
        };
      };
    };
}
