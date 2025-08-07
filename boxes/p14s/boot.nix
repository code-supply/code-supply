{
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.systemd-boot.configurationLimit = 25;

  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  boot.initrd.luks.devices."luks-26861216-bdc0-4196-a13f-1d9b8caaebfe".device =
    "/dev/disk/by-uuid/26861216-bdc0-4196-a13f-1d9b8caaebfe";
  boot.initrd.luks.devices."luks-26861216-bdc0-4196-a13f-1d9b8caaebfe".keyFile =
    "/crypto_keyfile.bin";
}
