{
  klix,
  ...
}:

{
  modules = klix.lib.machineImports.raspberry-pi-4 ++ [
    (
      { pkgs, config, ... }:
      {

        networking.hostName = "ketchup-king";
        time.timeZone = "Europe/London";
        users.users.klix.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOfher5cvUlwuLyrhTjbQSj8UWT7LTQ/eXd3rSXrJOFU"
        ];

        services.klix.configDir = ./klipper;
        services.klipper = {
          plugins = {
            kamp.enable = true;
            shaketune.enable = true;
            z_calibration.enable = true;
          };
        };

        services.klipperscreen.enable = true;
      }
    )
  ];
}
