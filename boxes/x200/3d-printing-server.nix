{
  pkgs,
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

  security.polkit.enable = true;

  services.moonraker = {
    enable = true;
    address = "0.0.0.0";
    allowSystemControl = true;
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
