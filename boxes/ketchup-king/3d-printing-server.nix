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
  environment.systemPackages = with pkgs; [
    klipperscreen
    xdotool
  ];

  boot = {
    plymouth = {
      enable = true;
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

  services.xserver = {
    enable = true;

    displayManager.session = [
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
    displayManager.lightdm.enable = true;
  };
  services.displayManager.defaultSession = "KlipperScreen";

  services.klipper.configFile = "${configs}/printer.cfg";
}
