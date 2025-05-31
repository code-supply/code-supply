{
  pkgs,
  config,
  ...
}:

let
  configs = pkgs.runCommand "create-printer-config" { } ''
    mkdir $out
    sed '/\[include extras\//! s#\[include \(.*\)\]#[include ${./klipper}/\1]#;s#\[include extras/#[include ${config.services.klipper.package}/lib/klipper/extras/#' \
      < ${./klipper/printer.cfg} \
      > $out/printer.cfg
  '';

  klipperscreen = pkgs.klipperscreen.overrideAttrs {
    src = pkgs.klipperscreenSrc;
  };
in

{
  environment.systemPackages = with pkgs; [
    isd
    lsof
  ];

  boot = {
    plymouth = {
      enable = true;
      logo = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/VoronDesign/Voron-Documentation/a74b763bb5eaa93d1e566d662de9f4d01caf44a1/images/voron_design_logo.png";
        hash = "sha256-6rWw6pX4VnPdNW9Xa9bZed9AllClfFO3RU0xTGZRmvY=";
      };
    };
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
    loader.timeout = 0;
  };

  programs.firefox.enable = false;
  programs.firefox.preferences = {
    "layout.css.devPixelsPerPx" = "1.5";
  };

  services.cage = {
    enable = true;
    user = "andrew";
    program = "${klipperscreen}/bin/KlipperScreen";
    extraArguments = [ "-ds" ];
  };

  services.klipper = {
    configFile = "${configs}/printer.cfg";
    plugins = {
      kamp.enable = true;
      shaketune.enable = true;
      z_calibration.enable = true;
    };
  };
}
