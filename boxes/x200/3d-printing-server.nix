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
  services.klipper.configFile = "${configs}/printer.cfg";
  services.moonraker.settings."webcam Sauron" = {
    service = "webrtc-go2rtc";
    target_fps = 30;
    stream_url = "http://x200.lan:1984/stream.html?src=cam1&mode=webrtc,mse,hls,mjpeg";
    aspect_ratio = "16:9";
  };

  environment.systemPackages = with pkgs; [
    v4l-utils
  ];

  services.go2rtc = {
    enable = true;
    settings = {
      api = {
        origin = "*";
      };
      streams = {
        cam1 = "ffmpeg:device?video=/dev/video0&input_format=h264&video_size=1920x1080";
      };
    };
  };
}
