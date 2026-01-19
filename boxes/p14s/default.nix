{
  nix,
  sops-nix,
  system,
  ...
}:

{
  inherit system;
  modules = [
    sops-nix.nixosModules.sops
    ./configuration.nix
    {
      nix.package = nix;
      sops.defaultSopsFile = ./secrets/klix.yaml;
    }
  ];
}
