{ websites, config, ... }:

{
  services.caddy = {
    enable = true;

    email = "me@andrewbruce.net";

    virtualHosts = {
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
