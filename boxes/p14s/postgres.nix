{ pkgs, ... }:

{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
    authentication = "local all postgres trust";
    identMap = "andrew_can_be_postgres andrew postgres";
  };
}
