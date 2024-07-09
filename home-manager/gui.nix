{ pkgs, ... }:
{
  home = {
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
    ];
  };
}
