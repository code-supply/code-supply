{ nix, nixpkgs, system, ... }:

nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    ./configuration.nix
    ({ nix.package = nix; })
  ];
}
