{ ipv4
, ipv6
, router-ipv4
, router-ipv6
, ...
}:

{
  config = {
    systemd.network = {
      enable = true;

      networks = {
        enp0s20f0u2 = {
          matchConfig = {
            Name = "enp0s20f0u2";
          };
          DHCP = "no";
          addresses = [
            { Address = "${ipv4}/24"; }
            { Address = "${ipv6}/64"; }
          ];
          dns = [
            "127.0.0.1"
            "::1"
          ];
          gateway = [
            "${router-ipv4}"
            "${router-ipv6}"
          ];
        };
      };
    };

    networking = {
      useDHCP = false;
      dhcpcd.enable = false;
      firewall.enable = false;
      hostName = "unhinged";
      # useNetworkd = true;
    };

    security.sudo.wheelNeedsPassword = false;

    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        UseDns = false;
      };
      listenAddresses = [
        {
          addr = "[::]";
          port = 2222;
        }
        {
          addr = "0.0.0.0";
          port = 2222;
        }
      ];
    };
  };
}
