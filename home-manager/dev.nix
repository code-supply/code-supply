{ pkgs, ... }:
{
  programs.rusty-git-mob.enable = true;

  home.packages = with pkgs; [
    nixfmt
  ];
}
