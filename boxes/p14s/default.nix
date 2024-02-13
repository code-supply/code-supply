{ nix, nixpkgs, system }:

nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    ../common/steam.nix
    ./configuration.nix
    ({ nix.package = nix; })
  ];
}
