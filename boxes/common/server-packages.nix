{
  isd,
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    btop
    dig
    htop
    isd.packages.aarch64-linux.default
    lsof
  ];
}
