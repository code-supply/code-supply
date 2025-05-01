{
  pkgs,
  ...
}:

let
  configs = pkgs.runCommand "create-printer-config" { } ''
    mkdir $out
    sed 's#\[include \(.*\)\]#[include ${./klipper}/\1]#' < ${./klipper/printer.cfg} > $out/printer.cfg
  '';

  sdbus =
    let
      pname = "sdbus";
      version = "0.14.0";
    in
    with pkgs;
    python3Packages.buildPythonPackage {
      inherit pname version;
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ systemd ];
      src = fetchPypi {
        inherit pname version;
        hash = "sha256-QdYbdswFqepB0Q1woR6fmobtlfQPcTYwxeGDQODkx28=";
      };
    };

  sdbusNetworkManager =
    let
      pname = "sdbus-networkmanager";
      version = "2.0.0";
    in
    with pkgs;
    python3Packages.buildPythonPackage {
      inherit pname version;
      propagatedBuildInputs = [ sdbus ];
      src = fetchPypi {
        inherit pname version;
        hash = "sha256-NXKsOoGJxoPsBBassUh2F3Oo8Iga09eLbW9oZO/5xQs=";
      };
    };

  klipperscreen = pkgs.klipperscreen.overridePythonAttrs (old: {
    pythonPath = old.pythonPath ++ [ sdbusNetworkManager ];
  });
in

{
  environment.systemPackages = with pkgs; [
    isd
    lsof
  ];

  boot = {
    plymouth = {
      enable = true;
      logo = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/VoronDesign/Voron-Documentation/a74b763bb5eaa93d1e566d662de9f4d01caf44a1/images/voron_design_logo.png";
        hash = "sha256-6rWw6pX4VnPdNW9Xa9bZed9AllClfFO3RU0xTGZRmvY=";
      };
    };
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
    loader.timeout = 0;
  };

  services.cage = {
    enable = true;
    user = "andrew";
    program = "${klipperscreen}/bin/KlipperScreen";
  };

  services.klipper.configFile = "${configs}/printer.cfg";
}
