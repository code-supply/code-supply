{ pkgs, ... }:
{
  home.packages = with pkgs; [
    spotify
    tetrio-desktop
  ];
}
