{ config, ... }:

let
  cfg = config.services.forgejo;
in
{
  services.forgejo = {
    enable = true;
    settings.server = {
      DISABLE_SSH = true;
      ROOT_URL = "https://forgejo.code.supply";
    };

    settings.service = {
      DISABLE_REGISTRATION = true;
    };
  };

  services.caddy = {
    virtualHosts.forgejo = {
      hostName = "forgejo.code.supply";

      extraConfig = ''
        encode gzip
        reverse_proxy localhost:${toString cfg.settings.server.HTTP_PORT}
      '';
    };
  };
}
