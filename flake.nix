{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        hostingBuild = with pkgs; with beamPackages;
          mixRelease {
            pname = "hosting";
            src = ./web/hosting;
            version = "0.0.0";
            mixNixDeps = import ./web/hosting/deps.nix { inherit lib beamPackages; };
          };
      in
      {
        defaultPackage = hostingBuild;
        devShells.default = import ./shell.nix { inherit pkgs; };
      }
    );
}
