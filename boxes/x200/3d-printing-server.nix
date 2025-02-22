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
    logFile = "/var/lib/klipper/klipper.log";
    user = "klipper";
    group = "klipper";
  };

  users = {
    users = {
      klipper = {
        isSystemUser = true;
        group = "klipper";
      };
      moonraker.extraGroups = [ "klipper" ];
    };
    groups.klipper = { };
  };

  services.moonraker = {
    enable = true;
    settings = {
      authorization = {
        force_logins = false;
        trusted_clients = [
          "0.0.0.0/0"
        ];
        cors_domains = [
          "*"
        ];
      };
    };
  };

  services.fluidd = {
    enable = true;
  };
}
