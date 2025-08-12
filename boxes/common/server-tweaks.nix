{
  boot.kernelParams = [ "consoleblank=5" ];
  services.logind.lidSwitch = "ignore";
  systemd.settings.Manager = {
    DefaultLimitNOFILE = "1048576";
  };

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
