{ pkgs, ... }:
{
  home = {
    file = {
      gnome-keyring-ssh = {
        target = ".config/autostart/gnome-keyring-ssh.desktop";
        text = ''
          [Desktop Entry]
          Type=Application
          Hidden=true
        '';
      };
    };

    packages = with pkgs; [
      gnome3.gnome-tweaks
    ];
  };

  dconf.settings = {
    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
    };
    "org/gnome/desktop/input-sources" = {
      xkb-options = [ "ctrl:swapcaps" ];
    };
  };
}

