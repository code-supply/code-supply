{ pkgs, ... }:

{
  environment.etc."xdg/autostart/steam.desktop" = {
    source = "${pkgs.steam}/share/applications/steam.desktop";
  };
}
