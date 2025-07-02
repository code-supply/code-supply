{
  isd,
  klix,
  ...
}:

{
  modules = [
    klix.nixosModules.default
    (
      { pkgs, config, ... }:
      {
        environment.systemPackages = with pkgs; [
          isd.packages.aarch64-linux.default
          lsof
        ];

        networking.hostName = "ketchup-king";
        time.timeZone = "Europe/London";
        system.stateVersion = "25.05";
        users.users.klix.openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCvEdU8Vs+25y3uN6YTFqNPKGdr7Z+v6lhuMQ0ppJ33pWPUh/AMMtumEr1Jb6+oAN7q4fozbu6o+9U1BlD0VXeIIAKaekru0tFzhcrvfQO8oiLs4f2TaQW8w5aprjmK8k5ZWdD2PV03jzxXnMhmFANr+zPgxLgy+J9JkoQJUcDBic1C1nbXLgHl7D0027aBT1NBGtK8ildCiDHmEh8qlCVJI6CSCS6fesZiHiyuEIVF1BG/DR9PWganyyuCHEav11fmiWiJAMUfCNwWosEoT4w0CTJ3vIhqeF9uAilo/NdUBGWJF/hLjWVFVoJ8uYjQyA70d0PY6mZjJgv+MUxsJoxYY1mQ+QqoIp3gF2/XAX1LwZPgd3Qh+cO2hkvBQ82g2TXqzu3bTSr/Gf4lUSmGPsozFhvkuRLL78wLefpY333NJ+ysp2XMwDDH0LEdQxeRbjlItpE7yEADiwe92RvsxxWgTFpHzMbxGaC95B0ZA2PUjY1izJQMPvGkV/4mx3QtC8wW/KeJJ52aWEO/Lcaec69bkKh56bOekipu6Jgs30e7CPtcgnMfllZRYbXvv05MlSKSTycgEMVssmjGEpKtVfIJiQUAhML4tQxfhZqy2t1/61tO2FgLDytoxLojQzJz9VOlsGcK7butCSJx3wrgCvU2Yc5fD3mskFJUJO+jFFqyMQ== cardno:16 019 463"
        ];

        services.klipper =
          let
            configs = pkgs.runCommand "create-printer-config" { } ''
              mkdir $out
              # all includes get replaced with the user's config dir as base
              # except: includes prefixed with extras/ get replaced with the klipper drv's extras dir, where plugins live
              sed '/\[include extras\//! s#\[include \(.*\)\]#[include ${./klipper}/\1]#;s#\[include extras/#[include ${config.services.klipper.package}/lib/klipper/extras/#' \
                < ${./klipper/printer.cfg} \
                > $out/printer.cfg
            '';
          in
          {
            configFile = "${configs}/printer.cfg";
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
