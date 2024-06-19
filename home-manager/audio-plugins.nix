{ pkgs, ... }:
{
  home = {
    sessionVariables = {
      LV2_PATH = "/home/andrew/.nix-profile/lib/lv2";
    };

    packages = with pkgs; [
      aether-lv2
      airwindows-lv2
      ams-lv2
      bespokesynth
      bschaffl
      calf
      carla
      ChowKick
      distrho
      drumgizmo
      drumkv1
      faust
      FIL-plugins
      geonkick
      gxmatcheq-lv2
      gxplugins-lv2
      ir.lv2
      LibreArp
      lsp-plugins
      mod-arpeggiator-lv2
      ninjas2
      rkrlv2
      sfizz
      surge-XT
      tamgamp.lv2
      x42-plugins
      zynaddsubfx
    ];
  };
}
