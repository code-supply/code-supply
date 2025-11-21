{ pkgs, ... }:
{
  home = {
    file = {
      pipewire-config =
        let
          json = pkgs.formats.json { };
        in
        {
          target = ".config/pipewire/pipewire.conf.d/92-low-latency.conf";
          source = json.generate "92-low-latency.conf" {
            context.properties = {
              default.clock.rate = 48000;
              default.clock.quantum = 16;
              default.clock.min-quantum = 16;
              default.clock.max-quantum = 16;
            };
          };
        };
    };

    packages = with pkgs; [
      (writeShellApplication {
        runtimeInputs = [
          xwax
        ];
        name = "xwax-run";
        text = ''
          set -m

          xwax -l ~/Music -j left -j right -g /2 -c -k &

          until pw-link -i | grep -q xwax
          do
            echo "Waiting for xwax..."
            sleep 0.1
          done

          pw-link alsa_input.usb-Allen_and_Heath_XONE_96_USB_2-00.multichannel-input:capture_AUX0 xwax:left_timecode_L
          pw-link alsa_input.usb-Allen_and_Heath_XONE_96_USB_2-00.multichannel-input:capture_AUX1 xwax:left_timecode_R

          pw-link alsa_input.usb-Allen_and_Heath_XONE_96_USB_2-00.multichannel-input:capture_AUX6 xwax:right_timecode_L
          pw-link alsa_input.usb-Allen_and_Heath_XONE_96_USB_2-00.multichannel-input:capture_AUX7 xwax:right_timecode_R

          pw-link xwax:left_playback_L alsa_output.usb-Allen_and_Heath_XONE_96_USB_2-00.multichannel-output:playback_AUX2
          pw-link xwax:left_playback_R alsa_output.usb-Allen_and_Heath_XONE_96_USB_2-00.multichannel-output:playback_AUX3

          pw-link xwax:right_playback_L alsa_output.usb-Allen_and_Heath_XONE_96_USB_2-00.multichannel-output:playback_AUX4
          pw-link xwax:right_playback_R alsa_output.usb-Allen_and_Heath_XONE_96_USB_2-00.multichannel-output:playback_AUX5

          fg
        '';
      })
      abcde
      alsa-scarlett-gui
      audacity
      bitwig-studio5
      elektroid
      mixxx
      pipecontrol
      qpwgraph
      xwax
    ];
  };
}
