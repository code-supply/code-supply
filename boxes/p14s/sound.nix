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

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
}
