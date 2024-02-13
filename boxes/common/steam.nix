{ pkgs, ... }: {
  config = {
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (pkgs.lib.getName pkg) [
        "steam"
        "steam-original"
        "steam-run"
      ];

    programs.steam.enable = true;
  };
}
