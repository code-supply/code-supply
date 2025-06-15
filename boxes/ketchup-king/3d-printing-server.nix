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
  };

  programs.firefox.enable = false;
  programs.firefox.preferences = {
    "layout.css.devPixelsPerPx" = "1.5";
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
