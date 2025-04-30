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
  environment.systemPackages = [
    pkgs.klipperscreen
    pkgs.xdotool
  ];

  services.xserver.enable = true;

  services.xserver.displayManager.session = [
    {
      name = "KlipperScreen";
      manage = "desktop";
      start = ''
        KlipperScreen &
        until xdotool search --class screen.py windowsize 100% 100%
        do
          sleep 0.1
        done
        waitPID=$!
      '';
    }
  ];
  services.displayManager.defaultSession = "KlipperScreen";
  services.xserver.displayManager.lightdm.enable = true;

  services.klipper = {
    configFile = "${configs}/printer.cfg";
  };
}
