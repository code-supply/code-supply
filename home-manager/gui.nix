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
      bless
      chromium
      gnome3.gnome-tweaks
      libreoffice
      nixos-generators
      signal-desktop
      transmission-gtk
      vlc
      wl-clipboard
      xclip
      xournal
      youtube-dl
    ];
  };

  dconf.settings = {
    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
    };
    "org/gnome/desktop/input-sources" = {
      xkb-options = [ "caps:ctrl_modifier" ];
    };
  };
}
