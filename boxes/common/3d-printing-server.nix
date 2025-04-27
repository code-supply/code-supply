{
  pkgs,
  ...
}:

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
      "webcam Sauron" = {
        service = "webrtc-go2rtc";
        target_fps = 30;
        stream_url = "http://x200.lan:1984/stream.html?src=cam1&mode=webrtc,mse,hls,mjpeg";
        aspect_ratio = "16:9";
      };
    };
  };

  services.fluidd = {
    enable = true;
  };
  services.nginx.clientMaxBodySize = "100m";
}
