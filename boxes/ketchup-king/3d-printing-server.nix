{
  pkgs,
  ...
}:

let
  configs = pkgs.runCommand "create-printer-config" { } ''
    mkdir $out
    sed 's#\[include \(.*\)\]#[include ${./klipper}/\1]#' < ${./klipper/printer.cfg} > $out/printer.cfg
  '';

  klipperZCalibration = pkgs.fetchFromGitHub {
    owner = "protoloft";
    repo = "klipper_z_calibration";
    rev = "487056ac07e7df082ea0b9acc7365b4a9874889e";
    hash = "sha256-WWP0LqhJ3ET4nxR8hVpq1uMOSK+CX7f3LXjOAZbRY8c=";
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

  services.cage = {
    enable = true;
    user = "andrew";
    program = "${pkgs.klipperscreen}/bin/KlipperScreen";
  };

  services.klipper = {
    configFile = "${configs}/printer.cfg";
    package = pkgs.klipper.overrideAttrs (old: {
      postUnpack = ''
        ln -s ${klipperZCalibration}/z_calibration.py source/klippy/extras/
      '';
    });
  };
}
