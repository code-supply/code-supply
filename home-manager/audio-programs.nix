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
              default.clock.force-quantum = 128;
            };
          };
        };
    };

    packages =
      with pkgs;
      let
        xwax-beta = xwax.overrideAttrs (
          finalAttrs: previousAttrs: {
            version = "1.10-beta1";

            src = fetchurl {
              url = "https://xwax.org/releases/xwax-${finalAttrs.version}.tar.gz";
              hash = "sha256-zJHkKhWXCKGhAYalUArYC6sLFX7NtWTu4yGY+60aB40=";
            };

            patches = [
              ./xwax-relative.patch
            ];

            postPatch = ''
              # font loading in xwax is relying on a hardcoded list of paths,
              # therefore we patch interface.c to also look up in the dejavu_fonts nix store path
              substituteInPlace interface.c \
                --replace-fail "/usr/X11R6/lib/X11/fonts/TTF" "${dejavu_fonts.outPath}/share/fonts/truetype/"

              # make paths to executed binaries hermetic:
              substituteInPlace import \
                --replace-fail "exec cdparanoia" "exec ${lib.getExe cdparanoia}" \
                --replace-fail "exec ffmpeg" "exec ${lib.getExe ffmpeg}"
            '';

            buildInputs = previousAttrs.buildInputs ++ [
              SDL2.dev
              SDL2_ttf
            ];

            configureFlags = [
              "--enable-jack"
            ];
          }
        );
      in
      [
        (writeShellApplication {
          runtimeInputs = [
            xwax-beta
          ];
          name = "xwax-run";
          text = ''
            set -m

            # shellcheck disable=SC2046
            xwax \
              --no-decor \
              --crate ~/audio-workspace/samples \
              --crate ~/Music \
              $(
              for pl in ~/Music/*.m3u
              do
                echo --crate "$pl"
              done
              ) \
              --timecode serato_2a_relative \
              --jack left \
              --jack right \
              --geometry /2 \
              --protect \
              &

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
        bpm-tools
        elektroid
        mixxx
        pipecontrol
        qpwgraph
        xwax-beta
      ];
  };
}
