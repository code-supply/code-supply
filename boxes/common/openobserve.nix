{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.services.openobserve;
in
{
  options.services.openobserve = {
    enable = mkEnableOption "openobserve";
    environmentFile = mkOption {
      default = builtins.toFile "defaultOOEnv" ''
        ZO_ROOT_USER_EMAIL=admin@example.com
        ZO_ROOT_USER_PASSWORD=admin
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.openobserve = {
      enable = true;
      wantedBy = [ "default.target" ];
      serviceConfig = {
        DynamicUser = true;
        Restart = "on-failure";
        LimitNOFILE = 65535;
        ExecStart = "${pkgs.openobserve}/bin/openobserve";
        ExecStop = "${pkgs.coreutils}/bin/kill -s QUIT $MAINPID";
        EnvironmentFile = cfg.environmentFile;
        StateDirectory = "openobserve";
        Environment = [ ''ZO_DATA_DIR="/var/lib/openobserve"'' ];
      };
    };
  };
}
