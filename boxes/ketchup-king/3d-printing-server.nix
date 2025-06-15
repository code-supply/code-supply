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
