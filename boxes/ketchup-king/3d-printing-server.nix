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
  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.displayManager.defaultSession = "gnome";

  services.klipper = {
    configFile = "${configs}/printer.cfg";
  };
}
