{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      gnome-tweaks
    ];
  };

  dconf.settings = {
    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "adaptive";
    };
    "org/gnome/desktop/input-sources" = {
      xkb-options = [ "ctrl:swapcaps" ];
    };
  };
}
