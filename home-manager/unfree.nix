{ pkgs, ... }:
{
  home.packages = with pkgs; [
    skypeforlinux
    spotify
    zoom-us
  ];
}
