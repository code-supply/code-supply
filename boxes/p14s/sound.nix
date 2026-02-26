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
    # allow andrew user to create realtime threads
    {
      domain = "andrew";
      item = "rtprio";
      type = "-";
      value = "99";
    }
  ];

  # https://github.com/mixxxdj/mixxx/wiki/Adjusting-Audio-Latency
  boot.kernelParams = [
    "nosmt"
    "threadirqs"
  ];

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;

    wireplumber.extraConfig = {
      "10-enable-pro-audio" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              {
                "device.name" = "~Scarlett.*";
              }
            ];
            actions = {
              update-props = {
                "device.profile" = "pro-audio";
              };
            };
          }
        ];
      };
    };
  };
}
