{ pkgs
, ...
}:

{
  # Scarlett 18i8 config
  boot.extraModprobeConfig = ''
    options snd_usb_audio vid=0x1235 pid=0x8214 device_setup=1
  '';

  # Give e.g. Ardour as much memory as it needs
  security.pam.loginLimits = [
    {
      domain = "*";
      item = "memlock";
      type = "-";
      value = "-1";
    }
  ];

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    wireplumber.configPackages = [
      (pkgs.writeTextDir
        "share/wireplumber/wireplumber.conf.d/disable-devices.conf"
        (builtins.readFile ./wireplumber/disable-devices.conf))
    ];
  };
}
