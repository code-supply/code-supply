{ pkgs, ipv4, ... }:

{
  nixpkgs.config.allowUnfree = true;

  hardware.printers =
    let
      name = "The_Inkredible_Bobby";
    in
    {
      ensurePrinters = [
        {
          inherit name;
          location = "69 Hillside";
          model = "samsung/ML-2010.ppd";
          deviceUri = "usb://Samsung/M2020%20Series?serial=ZFCEB8GF7C00YVL";
        }
      ];
      ensureDefaultPrinter = name;
    };

  services.printing = {
    enable = true;

    allowFrom = [ "all" ];
    browsing = true;
    defaultShared = true;
    drivers = [ pkgs.samsung-unified-linux-driver ];
    listenAddresses = [ "${ipv4}:631" ];
    openFirewall = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };
}
