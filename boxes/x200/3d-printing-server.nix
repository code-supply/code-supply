{
  pkgs,
  config,
  shubham-klipper,
  ...
}:

let
  mesh = ''
    [bltouch]
    z_offset: 0.303

    [bed_mesh default]
    version: 1
    points: 
      0.066250, -0.003750, -0.011250, 0.022500, 0.186250
      0.123750, 0.028750, -0.011250, -0.011250, 0.103750
      0.151250, 0.022500, -0.035000, -0.071250, 0.012500
      0.165000, 0.020000, -0.078750, -0.147500, -0.083750
      0.168750, 0.011250, -0.105000, -0.193750, -0.195000
    x_count: 5
    y_count: 5
    mesh_x_pps: 2
    mesh_y_pps: 2
    algo: bicubic
    tension: 0.2
    min_x: 10.0
    max_x: 206.0
    min_y: 10.0
    max_y: 210.48
  '';

  klipper_config = ''
    [virtual_sdcard]
    path: /var/lib/moonraker/gcodes

    [pause_resume]
    [display_status]

    [gcode_macro CANCEL_PRINT]
    description: Cancel the actual running print
    rename_existing: CANCEL_PRINT_BASE
    gcode:
      TURN_OFF_HEATERS
      CANCEL_PRINT_BASE
  '';
  printerConfig = pkgs.runCommand "create-printer-config" { } ''
    mkdir $out

    sed "/fluidd.cfg/d;s#macros.cfg#$out/macros.cfg#;s/mcu_temp/mcu/;s/raspberry_pi/host/" \
      < ${shubham-klipper}/printer.cfg \
      > $out/printer.cfg

    cat <<EOF >> $out/printer.cfg
    ${klipper_config}
    ${mesh}
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

  security.polkit = {
    enable = true;
    # https://github.com/Arksine/moonraker/blob/master/scripts/set-policykit-rules.sh
    extraConfig = ''
      polkit.addRule(function(action, subject) {
          if ((action.id == "org.freedesktop.systemd1.manage-units" ||
               action.id == "org.freedesktop.login1.power-off" ||
               action.id == "org.freedesktop.login1.power-off-multiple-sessions" ||
               action.id == "org.freedesktop.login1.reboot" ||
               action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
               action.id == "org.freedesktop.login1.halt" ||
               action.id == "org.freedesktop.login1.halt-multiple-sessions" ||
               action.id.startsWith("org.freedesktop.packagekit.")) &&
              subject.user == "${config.users.users.moonraker.name}") {
              var regex = "^Groups:.+${toString config.ids.gids.moonraker}";
              var cmdpath = "/proc/" + subject.pid.toString() + "/status";
              try {
                  polkit.spawn(["grep", "-Po", regex, cmdpath]);
                  return polkit.Result.YES;
              } catch (error) {
                  return polkit.Result.NOT_HANDLED;
              }
          }
      });
    '';
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
    address = "0.0.0.0";
    settings = {
      octoprint_compat = { };
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
