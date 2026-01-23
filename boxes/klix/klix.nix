{
  config,
  nix,
  pkgs,
  klixUrl,
  websites,
  ...
}:

{
  imports = [ ../common/openobserve.nix ];

  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "klix-remote";
      text = ''
        set -a
        # shellcheck source=/dev/null
        source ${config.sops.secrets."klix/environment".path}
        ${websites.klix}/bin/klix remote
      '';
    })
    klixUrl
  ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
    };
  };

  users = {
    groups.klix = { };
    users.klix = {
      isSystemUser = true;
      group = "klix";
      home = "/var/klix";
      createHome = true;
    };
  };

  systemd.services.klix = {
    enable = true;
    wantedBy = [ "default.target" ];
    path = [ nix ];
    serviceConfig = {
      User = "klix";
      Restart = "always";
      ExecStartPre = "${websites.klix}/bin/migrate";
      ExecStart = "${websites.klix}/bin/server";
      KillMode = "mixed";
      EnvironmentFile = config.sops.secrets."klix/environment".path;
    };
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;

    ensureDatabases = [
      "klix"
    ];

    ensureUsers = [
      {
        name = "klix";
        ensureDBOwnership = true;
      }
    ];

    authentication = "local all postgres trust";
    identMap = "andrew_can_be_postgres andrew postgres";
  };

  environment.sessionVariables = {
    PGDATABASE = "klix";
    PGUSER = "postgres";
  };

  services.postgresqlBackup.enable = true;

  sops.secrets."klix/environment" = {
    restartUnits = [ "klix.service" ];
    owner = "klix";
    group = "klix";
  };

  sops.secrets."openobserve/environment" = { };

  services.caddy = {
    enable = true;
    email = "me@andrewbruce.net";

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

      openobserve = {
        hostName = "openobserve.klix.code.supply";

        extraConfig = ''
          encode gzip
          reverse_proxy localhost:5080
        '';
      };
    };
  };
}
