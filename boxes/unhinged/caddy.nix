{ websites, ... }:

{
  systemd.user.services.klix = {
    enable = true;
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Restart = "always";
      ExecStart = "${websites.klix}/bin/klix start";
      KillMode = "mixed";
    };
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

      www-andrewbruce = {
        hostName = "www.andrewbruce.net";

        extraConfig = ''
          encode gzip
          root * ${websites.andrewbruce}
          file_server
        '';
      };

      andrewbruce = {
        hostName = "andrewbruce.net";

        extraConfig = ''
          redir https://www.andrewbruce.net{uri} permanent
        '';
      };

      codesupply = {
        hostName = "code.supply";

        extraConfig = ''
          encode gzip
          root * ${websites.codesupply}
          file_server
        '';
      };

      codesupply-www = {
        hostName = "www.code.supply";

        extraConfig = ''
          redir https://code.supply{uri} permanent
        '';
      };
    };
  };
}
