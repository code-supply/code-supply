{ pkgs, ... }:

with pkgs;

{
  home.packages = [
    appimage-run
    blender
    bootterm
    cura-appimage
    freecad
    inkscape
    klipper
    openscad
    orca-slicer
  ];

  programs.nixvim = {
    autoCmd = [
      {
        command = "set commentstring=//\\ %s";
        event = [
          "BufRead"
        ];
        pattern = [
          "*.scad"
        ];
      }
    ];
    plugins.lsp.servers.openscad_lsp = {
      enable = true;
    };
  };
}
