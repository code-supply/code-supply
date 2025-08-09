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
      abcde
      alsa-scarlett-gui
      audacity
      bitwig-studio5
      elektroid
      mixxx
      pipecontrol
      qpwgraph
    ];
  };
}
