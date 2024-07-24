{ pkgs, ... }:
{
  xdg.desktopEntries = {
    audacity = {
      name = "Audacity";
      genericName = "Sound Editor";
      icon = "audacity";
      type = "Application";
      categories = [ "AudioVideo" "Audio" "AudioVideoEditing" ];
      exec = "env GDK_BACKEND=x11 audacity %F";
      mimeType = [
        "application/x-audacity-project"
        "audio/aac"
        "audio/ac3"
        "audio/mp4"
        "audio/x-ms-wma"
        "video/mpeg"
        "audio/flac"
        "audio/x-flac"
        "audio/mpeg"
        "application/ogg"
        "audio/x-vorbis+ogg"
      ];
    };
  };

  home = {
    file =
      let
        drivenByMoss =
          pkgs.fetchzip {
            url = "https://www.mossgrabers.de/Software/Bitwig/DrivenByMoss-23.2.2-Bitwig.zip";
            hash = "sha256-+9EKyeYgGKVIt+34Dgcz2xK4sZ7w72424RLspB5+05Q=";
            stripRoot = false;
          };
      in
      {
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
        drivenByMossBitwigExtension =
          {
            target = "Bitwig Studio/Extensions/DrivenByMoss.bwextension";
            source = "${drivenByMoss}/DrivenByMoss.bwextension";
          };
      };

    packages = with pkgs; [
      abcde
      alsa-scarlett-gui
      ardour
      audacity
      # bitwig-studio5
      (
        bitwig-studio5.overrideAttrs (finalAttrs: previousAttrs: {
          version = "5.2 Beta 13";
          buildInputs = previousAttrs.buildInputs ++ [ vulkan-loader ];
          src = fetchurl {
            url = "https://www.bitwig.com/dl/Bitwig%20Studio/5.2%20Beta%2013/installer_linux/";
            hash = "sha256-+/LxVjqE3i14K6Pd3ULrCXADu9f9iUKsqtzLRsjPC9Q=";
          };
          postFixup = ''
            # patchelf fails to set rpath on BitwigStudioEngine, so we use
            # the LD_LIBRARY_PATH way

            find $out -type f -executable \
              -not -name '*.so.*' \
              -not -name '*.so' \
              -not -name '*.jar' \
              -not -name 'jspawnhelper' \
              -not -path '*/resources/*' | \
            while IFS= read -r f ; do
              patchelf --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" $f
              # make xdg-open overrideable at runtime
              wrapProgram $f \
                "''${gappsWrapperArgs[@]}" \
                --prefix PATH : "${lib.makeBinPath [ ffmpeg ]}" \
                --suffix PATH : "${lib.makeBinPath [ xdg-utils ]}" \
                --suffix LD_LIBRARY_PATH : "${lib.strings.makeLibraryPath (previousAttrs.buildInputs ++ [ vulkan-loader ])}"
            done

            find $out -type f -executable -name 'jspawnhelper' | \
            while IFS= read -r f ; do
              patchelf --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" $f
            done
          '';
        })
      )
      carla
      easyeffects
      elektroid
      ft2-clone
      helvum
      hydrogen
      lmms
      mixxx
      pianobooster
      polyphone
      qjackctl
      qpwgraph
      reaper
      scdl
      sooperlooper
    ];
  };
}
