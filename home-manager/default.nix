{
  home-manager,
  pkgs,
  nixvim,
  git-mob,
  catppuccin,
}:

home-manager.lib.homeManagerConfiguration {
  inherit pkgs;

  modules = [
    ./audio-plugins.nix
    ./audio-programs.nix
    catppuccin.homeManagerModules.catppuccin
    ./cli.nix
    ./dev.nix
    ./firefox.nix
    git-mob.nixosModules.homeManager
    ./git.nix
    ./gnome.nix
    ./graphics.nix
    ./gui.nix
    ./home.nix
    ./k8s.nix
    ./kitty.nix
    ./nixvim
    nixvim.homeManagerModules.nixvim
    ./theme.nix
    ./unfree.nix
  ];

  extraSpecialArgs = {
    git-mob = git-mob.packages.x86_64-linux.default;
  };
}
