{
  pkgs,
  ...
}:

let
  configs = pkgs.runCommand "create-printer-config" { } ''
    mkdir $out
    sed 's#\[include \(.*\)\]#[include ${./klipper}/\1]#' < ${./klipper/printer.cfg} > $out/printer.cfg
  '';
in

{
  services.klipper = {
    configFile = "${configs}/printer.cfg";
    package =
      (pkgs.pkgsCross.aarch64-multiplatform.klipper.override {
        python3 = pkgs.buildPackages.python3;
      }).overrideAttrs
        ({
          postBuild = ''
            python ./chelper/__init__.py || true
          '';
        });
  };
}
