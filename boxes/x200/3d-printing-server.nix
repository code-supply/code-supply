{
  shubham-klipper,
  ...
}:

{
  services.klipper = {
    enable = true;
    configFile = "${shubham-klipper}/printer.cfg";
  };

  services.fluidd = {
    enable = true;
  };
}
