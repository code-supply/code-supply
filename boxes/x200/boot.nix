{
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";

    extraEntries = ''
      menuentry "NixOS iomem relaxed" --class nixos --unrestricted {
      search --set=drive1 --fs-uuid 1C70-1ADC
        linux ($drive1)//kernels/szr6ammf9641354w3qk1b055akm7d6vc-linux-6.12.10-bzImage init=/nix/store/q929lfkpdgh2j7sn63f87izhkr4skk0j-nixos-system-x200-25.05.20250123.0aa4755/init loglevel=4 iomem=relaxed
        initrd ($drive1)//kernels/qzhxqrr34rwpng5fd3qlyqzjmzvlfl3i-initrd-linux-6.12.10-initrd
      }
    '';
  };
}
