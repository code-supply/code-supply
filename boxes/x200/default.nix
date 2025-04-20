{
  nix,
  system,
  ...
}:

{
  inherit system;
  modules = [
    ./configuration.nix
    ../common/ssh.nix
    { nix.package = nix; }
  ];
}
