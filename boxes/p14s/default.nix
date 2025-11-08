{
  isd,
  nix,
  system,
  ...
}:

{
  inherit system;
  modules = [
    ./configuration.nix
    { nix.package = nix; }
  ];
  specialArgs = {
    inherit isd;
  };
}
