{
  boot.blacklistedKernelModules = [
    "ath10k_pci"
    "btusb"
    "uvcvideo"
  ];
  boot.kernelParams = [ "consoleblank=5" ];

  services.logind.lidSwitch = "ignore";

  systemd.extraConfig = ''
    DefaultLimitNOFILE=1048576
  '';

  security.pam.loginLimits = [
    {
      domain = "*";
      item = "nofile";
      type = "-";
      value = "unlimited";
    }
    {
      domain = "*";
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
  ];
}
