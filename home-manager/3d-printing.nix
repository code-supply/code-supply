{ pkgs, ... }:

{
  home.packages = with pkgs; [
    appimage-run
    blender
    cura-appimage
    prusa-slicer
  ];
}
