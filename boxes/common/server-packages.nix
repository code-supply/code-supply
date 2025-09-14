{
  isd,
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    htop
    isd.packages.aarch64-linux.default
    lsof
  ];
}
