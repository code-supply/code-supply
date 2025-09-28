{
  config,
  nix,
  websites,
  pkgs,
  ...
}:

{
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

    ensureDatabases = [
      "klix"
    ];

    ensureUsers = [
      {
        name = "klix";
        ensureDBOwnership = true;
      }
    ];
  };

  sops.secrets."klix/environment" = {
    restartUnits = [ "klix.service" ];
    owner = "klix";
    group = "klix";
  };

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
    };
  };
}
