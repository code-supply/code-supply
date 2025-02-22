{
  home-manager,
  pkgs,
}:

home-manager.lib.homeManagerConfiguration {
  inherit pkgs;

  modules = [
    ./cli.nix
    ./dev.nix
    ./git.nix
    ./home.nix
    ./neovim
  ];
}
