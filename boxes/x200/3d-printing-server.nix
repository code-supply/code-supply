{
  shubham-klipper,
  ...
}:

{
  services.klipper = {
    enable = true;
    configFile = "${shubham-klipper}/printer.cfg";
  };
}
