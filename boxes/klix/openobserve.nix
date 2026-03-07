{ config, ... }:
{
  services.openobserve = {
    enable = true;
    environmentFile = "${config.sops.secrets."openobserve/environment".path}";
  };
}
