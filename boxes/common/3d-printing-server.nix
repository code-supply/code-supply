{
  services.klipper = {
    enable = true;
    logFile = "/var/lib/klipper/klipper.log";
    user = "klipper";
    group = "klipper";
  };

  users = {
    users = {
      klipper = {
        isSystemUser = true;
        group = "klipper";
        home = "/home/klipper";
        createHome = true;
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
      file_manager = {
        enable_object_processing = true;
      };
    };
  };

  services.fluidd = {
    enable = true;
  };
  services.nginx.clientMaxBodySize = "100m";
}
