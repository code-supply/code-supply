{
  pkgs,
  shubham-klipper,
  ...
}:

let
  printerConfig = pkgs.runCommand "create-printer-config" { } ''
    mkdir $out

    sed "/fluidd.cfg/d;s#macros.cfg#$out/macros.cfg#" \
      < ${shubham-klipper}/printer.cfg \
      > $out/printer.cfg

    cp ${shubham-klipper}/macros.cfg $out/
  '';
in

{
  services.klipper = {
    enable = true;
    configFile = "${printerConfig}/printer.cfg";
  };

  services.moonraker = {
    enable = true;
  };

  users.groups.klipper.members = [ "moonraker" ];

  services.fluidd = {
    enable = true;
  };
}
