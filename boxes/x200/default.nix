{
  home-manager,
  nix,
  system,
  ...
}:

{
  inherit system;
  modules = [
    ./configuration.nix
    home-manager.nixosModules.home-manager
    { nix.package = nix; }
  ];
}
