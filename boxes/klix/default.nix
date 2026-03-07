{
  nix,
  sops-nix,
  klixUrl,
  websites,
  ...
}:

{
  system = "aarch64-linux";
  modules = [
    sops-nix.nixosModules.sops
    (
      { config, ... }:
      {
        boot.growPartition = true;
        boot.loader.grub.configurationLimit = 5;
        boot.tmp.cleanOnBoot = true;
        services.openobserve = {
          enable = true;
          environmentFile = "${config.sops.secrets."openobserve/environment".path}";
        };
        sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        sops.defaultSopsFile = ./secrets/klix.yaml;
        system.stateVersion = "23.11";
        networking.domain = "";
        networking.hostName = "klix";
        users.users.root.openssh.authorizedKeys.keys = [
          ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCvEdU8Vs+25y3uN6YTFqNPKGdr7Z+v6lhuMQ0ppJ33pWPUh/AMMtumEr1Jb6+oAN7q4fozbu6o+9U1BlD0VXeIIAKaekru0tFzhcrvfQO8oiLs4f2TaQW8w5aprjmK8k5ZWdD2PV03jzxXnMhmFANr+zPgxLgy+J9JkoQJUcDBic1C1nbXLgHl7D0027aBT1NBGtK8ildCiDHmEh8qlCVJI6CSCS6fesZiHiyuEIVF1BG/DR9PWganyyuCHEav11fmiWiJAMUfCNwWosEoT4w0CTJ3vIhqeF9uAilo/NdUBGWJF/hLjWVFVoJ8uYjQyA70d0PY6mZjJgv+MUxsJoxYY1mQ+QqoIp3gF2/XAX1LwZPgd3Qh+cO2hkvBQ82g2TXqzu3bTSr/Gf4lUSmGPsozFhvkuRLL78wLefpY333NJ+ysp2XMwDDH0LEdQxeRbjlItpE7yEADiwe92RvsxxWgTFpHzMbxGaC95B0ZA2PUjY1izJQMPvGkV/4mx3QtC8wW/KeJJ52aWEO/Lcaec69bkKh56bOekipu6Jgs30e7CPtcgnMfllZRYbXvv05MlSKSTycgEMVssmjGEpKtVfIJiQUAhML4tQxfhZqy2t1/61tO2FgLDytoxLojQzJz9VOlsGcK7butCSJx3wrgCvU2Yc5fD3mskFJUJO+jFFqyMQ==''
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOfher5cvUlwuLyrhTjbQSj8UWT7LTQ/eXd3rSXrJOFU"
        ];
        zramSwap.enable = true;
      }
    )
    ../common/locale.nix
    ../common/nix.nix
    ../common/openobserve.nix
    ../common/server-packages.nix
    ../common/user.nix
    ./hardware-configuration.nix
    ./klix.nix
    ./networking.nix # generated at runtime by nixos-infect
    ./other-websites.nix
  ];
  specialArgs = {
    inherit
      nix
      websites
      klixUrl
      ;
  };
}
