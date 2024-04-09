{ nix, nixpkgs, system, ... }:

nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    ../common/gui.nix
    ../common/locale.nix
    ../common/nix.nix
    ../common/steam.nix
    ../common/user.nix
    ./configuration.nix
    ./hardware-configuration.nix
    ./joycon.nix
    ({ nix.package = nix; })
    ./nvidia.nix
    ./steam-console.nix
    ./system76.nix
  ];
}
