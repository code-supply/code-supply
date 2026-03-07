{ config, ... }:
{
  imports = [ ../common/openobserve.nix ];

  services.caddy = {
    virtualHosts.openobserve = {
      hostName = "openobserve.klix.code.supply";

      extraConfig = ''
        encode gzip
        reverse_proxy localhost:5080
      '';

    };
  };

  services.openobserve = {
    enable = true;
    environmentFile = "${config.sops.secrets."openobserve/environment".path}";
  };

  sops.secrets."openobserve/environment" = { };
}
