{ nix, nixpkgs, system, ... }:

nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    ../common/locale.nix
    ../common/nix.nix
    ../common/user.nix
    ./configuration.nix
    ./hardware-configuration.nix
    ({ nix.package = nix; })
    ./nvidia.nix
    ./steam-console.nix
    ./system76.nix
  ];
}
