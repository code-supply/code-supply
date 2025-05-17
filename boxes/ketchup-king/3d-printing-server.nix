{
  pkgs,
  ...
}:

let
  configs = pkgs.runCommand "create-printer-config" { } ''
    mkdir $out
    sed '/\[include .\/KAMP/! s#\[include \(.*\)\]#[include ${./klipper}/\1]#;s#\[include ./KAMP#[include ${kamp}/Configuration#' \
      < ${./klipper/printer.cfg} \
      > $out/printer.cfg
  '';

  kamp = pkgs.fetchFromGitHub {
    owner = "kyleisah";
    repo = "Klipper-Adaptive-Meshing-Purging";
    rev = "b0dad8ec9ee31cb644b94e39d4b8a8fb9d6c9ba0";
    hash = "sha256-05l1rXmjiI+wOj2vJQdMf/cwVUOyq5d21LZesSowuvc=";
  };

  klipperZCalibration = pkgs.fetchFromGitHub {
    owner = "protoloft";
    repo = "klipper_z_calibration";
    rev = "487056ac07e7df082ea0b9acc7365b4a9874889e";
    hash = "sha256-WWP0LqhJ3ET4nxR8hVpq1uMOSK+CX7f3LXjOAZbRY8c=";
  };

  shakeTune = pkgs.fetchFromGitHub {
    owner = "Frix-x";
    repo = "klippain-shaketune";
    rev = "c8ef451ec4153af492193ac31ed7eea6a52dbe4e";
    hash = "sha256-zzskp7ZiwR7nJ2e5eTCyEilctDoRxZdBn90zncFm0Rw=";
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
    package = (
      pkgs.klipper.overrideAttrs {
        buildInputs = [
          (pkgs.python3.withPackages (
            p: with p; [
              # original deps
              python-can
              cffi
              pyserial
              greenlet
              jinja2
              markupsafe
              numpy

              # shaketune deps
              GitPython
              matplotlib
              numpy
              scipy
              pywavelets
              zstandard
            ]
          ))
        ];
        postUnpack = ''
          ln -sfv ${klipperZCalibration}/z_calibration.py source/klippy/extras/
          ln -sfv ${shakeTune}/shaketune source/klippy/extras/shaketune
          ln -sfv ${kamp}/Configuration source/klippy/extras/KAMP
        '';
      }
    );
  };
}
