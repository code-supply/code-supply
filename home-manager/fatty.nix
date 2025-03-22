{
  home-manager,
  pkgs,
  git-mob,
}:

home-manager.lib.homeManagerConfiguration {
  inherit pkgs;

  modules = [
    ./cli.nix
    ./dev.nix
    ./firefox.nix
    git-mob.nixosModules.homeManager
    ./git.nix
    ./gnome.nix
    ./gnome-no-overview.nix
    ./graphics.nix
    ./home.nix
    ./k8s.nix
    ./kitty.nix
    ./nixvim
  ];
}
