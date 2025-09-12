{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      chromium
      libreoffice
      nixos-generators
      protonvpn-gui
      signal-desktop
      transmission_4-gtk
      vlc
      wl-clipboard
      xclip
      xournalpp
    ];
  };
}
