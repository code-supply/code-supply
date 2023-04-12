{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        beamPkgs = with pkgs.beam_minimal; packagesWith interpreters.erlangR25;
        erlang = beamPkgs.erlang;
        elixir = beamPkgs.elixir_1_14;

        fetchMixDeps = beamPkgs.fetchMixDeps.override { inherit elixir; };
        buildMix' = beamPkgs.buildMix'.override { inherit fetchMixDeps; };
        mixRelease = beamPkgs.mixRelease.override { inherit elixir erlang fetchMixDeps; };
        version = builtins.readFile ./web/hosting/VERSION;

        buildHosting = with pkgs; with beamPackages;
          mixRelease {
            pname = "hosting";
            src = ./web/hosting;
            version = version;
            mixNixDeps = import ./web/hosting/deps.nix { inherit lib beamPackages; };
          };
        dockerImageHosting = pkgs.dockerTools.buildImage
          {
            name = "codesupplydocker/hosting";
            tag = version;
            config = {
              Cmd = [ "${buildHosting}/bin/hosting" "start" ];
              Env = [ "PATH=/bin:$PATH" ];
            };
            copyToRoot = pkgs.buildEnv {
              name = "image-root";
              paths = with pkgs; [
                bash
                coreutils
                gnused
              ];
              pathsToLink = [ "/bin" ];
            };
          };
      in
      {
        packages = {
          hosting = buildHosting;
          docker = dockerImageHosting;
        };
        defaultPackage = buildHosting;
        devShells.default = import ./shell.nix { inherit pkgs; };
      }
    );
}
