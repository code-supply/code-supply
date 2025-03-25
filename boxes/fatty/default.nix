{ nix, system, ... }:

{
  inherit system;
  modules = [
    ../common/disable-tracker-miner.nix
    ../common/gpg-ssh.nix
    ../common/gui.nix
    ../common/locale.nix
    ../common/server-nix.nix
    ../common/steam.nix
    ../common/user.nix
    ./configuration.nix
    ./hardware-configuration.nix
    ./network.nix
    ({ nix.package = nix; })
    ./nvidia.nix
    ./steam-console.nix
    ./system76.nix
  ];
}
