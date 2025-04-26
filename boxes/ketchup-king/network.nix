{
  networking = {
    firewall.enable = false;
    hostName = "ketchup-king";
    wireless.enable = true;
    wireless.secretsFile = "/var/secrets/wireless.conf";
    wireless.networks = {
      vegUpstairs2g = {
        pskRaw = "ext:psk_vegetables2ghz";
        extraConfig = ''
          ssid="VegUpstairs2G"
        '';
      };
    };
  };
  security.sudo.wheelNeedsPassword = false;
}
