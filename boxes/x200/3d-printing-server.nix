{
  pkgs,
  config,
  ...
}:

let
  configs = pkgs.runCommand "create-printer-config" { } ''
    mkdir $out
    sed 's#\[include \(.*\)\]#[include ${./klipper}/\1]#' < ${./klipper/printer.cfg} > $out/printer.cfg
  '';
in

{
  services.klipper = {
    enable = true;
    configFile = "${configs}/printer.cfg";
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
