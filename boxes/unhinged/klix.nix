{ config, websites, ... }:

{
  users = {
    groups.klix = { };
    users.klix = {
      isSystemUser = true;
      group = "klix";
    };
  };

  systemd.services.klix = {
    enable = true;
    wantedBy = [ "default.target" ];
    serviceConfig = {
      User = "klix";
      Restart = "always";
      ExecStart = "${websites.klix}/bin/klix start";
      KillMode = "mixed";
      EnvironmentFile = config.sops.secrets."klix/environment".path;
    };
  };

  sops.secrets."klix/environment" = {
    restartUnits = [ "klix.service" ];
    owner = "klix";
    group = "klix";
  };

  services.caddy = {
    virtualHosts = {
      klix = {
        hostName = "klix.code.supply";

        extraConfig = ''
          encode gzip
          root * ${websites.klix}
          reverse_proxy localhost:4000
        '';
      };

      klix-www = {
        hostName = "www.klix.code.supply";

        extraConfig = ''
          redir https://klix.code.supply{uri} permanent
        '';
      };
    };
  };
}
