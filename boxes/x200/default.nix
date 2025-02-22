{
  nix,
  system,
  shubham-klipper,
  ...
}:

{
  inherit system;
  modules = [
    ./configuration.nix
    { nix.package = nix; }
  ];
  specialArgs = { inherit shubham-klipper; };
}
