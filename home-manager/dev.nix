{ pkgs, ... }:
{
  programs.rusty-git-mob.enable = true;

  home.packages = with pkgs; [
    alejandra
    nil
    nixpkgs-fmt
    rnix-lsp
    sumneko-lua-language-server
  ];
}
