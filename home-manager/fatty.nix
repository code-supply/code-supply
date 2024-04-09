{ home-manager, pkgs, git-mob }:

home-manager.lib.homeManagerConfiguration {
  inherit pkgs;

  modules = [
    git-mob.nixosModules.homeManager
    ./cli.nix
    ./dev.nix
    ./firefox.nix
    ./git.nix
    ./graphics.nix
    ./gui.nix
    ./home.nix
    ./k8s.nix
    ./kitty.nix
    ./neovim
    ./gnome-no-overview.nix
  ];
}
