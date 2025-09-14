{
  isd,
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    dig
    htop
    isd.packages.aarch64-linux.default
    lsof
  ];
}
