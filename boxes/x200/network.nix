{
  networking = {
    hostName = "x200";
    firewall.enable = false;
    wireless.enable = true;
    wireless.secretsFile = "/var/secrets/wireless.conf";
    wireless.networks.vegetables2ghz = {
      pskRaw = "ext:psk_vegetables2ghz";
      extraConfig = ''
        ssid="Vegetables 2Ghz"
      '';
    };
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
