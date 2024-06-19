{ pkgs, lib, ... }:
{
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "reaper"
      "skypeforlinux"
      "spotify"
      "zoom"
    ];

  home.packages = with pkgs; [
    skypeforlinux
    spotify
    zoom-us
  ];
}
