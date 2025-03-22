{
  networking = {
    hostName = "fatty";
    firewall.enable = false;
  };

  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      UseDns = false;
    };
  };
}
