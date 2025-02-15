{
  inputs,
  pkgs,
  lib,
  ...
}: {
  services = {
    ledger-ssh-agent = {
      name = "ledger-ssh-agent";
      command = "${pkgs.openssh}/bin/ssh-agent -D -a /tmp/ledger-ssh-agent.sock";
      properties = {
        restartOn.failure = true;
        keepAlive = true;
      };
    };
  };
}
