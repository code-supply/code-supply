{ home-manager, pkgs, git-mob }:

home-manager.lib.homeManagerConfiguration {
  inherit pkgs;

  modules = [
    git-mob.nixosModules.homeManager
    ./audio-plugins.nix
    ./audio-programs.nix
    ./cli.nix
    ./dev.nix
    ./firefox.nix
    ./git.nix
    ./graphics.nix
    ./gui.nix
    ./home.nix
    ./k8s.nix
    ./kitty.nix
    ./neovim.nix
    ./unfree.nix
  ];

  extraSpecialArgs = {
    git-mob = git-mob.packages.x86_64-linux.default;
  };
}
