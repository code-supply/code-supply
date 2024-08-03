{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      bless
      chromium
      libreoffice
      nixos-generators
      signal-desktop
      transmission_4-gtk
      vlc
      wl-clipboard
      xclip
      xournal
    ];
  };
}
