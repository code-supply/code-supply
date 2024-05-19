{ pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.windowManager.openbox.enable = true;

  programs.steam.enable = true;

  environment.etc = {
    "xdg/autostart/steam.desktop" = {
      source = "${pkgs.steam}/share/applications/steam.desktop";
    };
    "xdg/openbox/rc.xml" = {
      source = ./openbox-rc.xml;
    };
    "xdg/openbox/menu.xml" = {
      source = ./openbox-menu.xml;
    };
  };
}
