{ pkgs, ... }:

{
  home.packages = with pkgs; [
    appimage-run
    blender
    prusa-slicer
  ];
}
