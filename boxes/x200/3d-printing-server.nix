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

    echo "[virtual_sdcard]" >> $out/printer.cfg
    echo "path: /var/lib/moonraker/gcodes" >> $out/printer.cfg
    echo >> $out/printer.cfg
    echo "[pause_resume]" >> $out/printer.cfg
    echo "[display_status]" >> $out/printer.cfg
    cat <<EOF >> $out/printer.cfg
    [gcode_macro CANCEL_PRINT]
    description: Cancel the actual running print
    rename_existing: CANCEL_PRINT_BASE
    gcode:
      TURN_OFF_HEATERS
      CANCEL_PRINT_BASE
    EOF

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

  security.polkit.enable = true;

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
