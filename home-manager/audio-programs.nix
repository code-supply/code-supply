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
      bitwig-studio5
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
