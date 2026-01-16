{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      arduino-ide
      chromium
      libreoffice
      nixos-generators
      proton-pass
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
