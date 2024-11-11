{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      chromium
      libreoffice
      nixos-generators
      signal-desktop
      transmission_4-gtk
      vlc
      wl-clipboard
      xclip
      xournalpp
    ];
  };
}
