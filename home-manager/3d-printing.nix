{ pkgs, ... }:

with pkgs;

{
  home.packages = [
    appimage-run
    blender
    cura-appimage
    inkscape
    openscad-unstable
    prusa-slicer
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
      package = openscad-lsp.override (
        let
          rp = rustPlatform;
        in
        {
          rustPlatform = rp // {
            buildRustPackage =
              args:
              rp.buildRustPackage (
                args
                // {
                  src = fetchFromGitHub {
                    owner = "Leathong";
                    repo = "openscad-LSP";
                    rev = "d6501c05a890f576c1f25c6aa2868cbada4a1d6e";
                    hash = "sha256-BNHoPMWjZC0dtD9/OUvgx/WPzqAOhhmXVkutCG2SybA=";
                  };
                  cargoHash = "sha256-JaX/BokVeHcD/38zbUFYucAqpASSxV9gvvjYvjX7xdA=";
                }
              );
          };
        }
      );
    };
  };
}
