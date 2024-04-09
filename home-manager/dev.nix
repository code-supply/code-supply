{ pkgs, ... }:
{
  programs.rusty-git-mob.enable = true;

  home.packages = with pkgs; [
    nil
    nixpkgs-fmt
    sumneko-lua-language-server
  ];
}
