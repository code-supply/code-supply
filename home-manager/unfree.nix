{ pkgs, ... }:
{
  home.packages = with pkgs; [
    skypeforlinux
    spotify
    tetrio-desktop
    zoom-us
  ];
}
