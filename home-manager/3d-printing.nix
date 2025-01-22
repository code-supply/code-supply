{ pkgs, ... }:

{
  home.packages = with pkgs; [
    blender
    prusa-slicer
  ];
}
