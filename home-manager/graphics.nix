{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ffmpeg
    gimp
    imagemagick
    kdenlive
  ];
}
