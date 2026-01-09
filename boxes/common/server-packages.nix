{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    btop
    dig
    htop
    isd
    lsof
  ];
}
