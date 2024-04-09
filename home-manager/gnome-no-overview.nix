{ pkgs, ... }:
with pkgs;
{
  home.packages = [
    pkgs.gnomeExtensions.no-overview
  ];

  dconf.settings = {
    "org/gnome/shell"."enabled-extensions" = [
      gnomeExtensions.no-overview.extensionUuid
    ];
  };
}
