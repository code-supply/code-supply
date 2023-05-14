{
  nixConfig.sandbox = "relaxed";

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
        version = nixpkgs.lib.strings.removeSuffix "\n" (builtins.readFile ./web/hosting/VERSION);

        buildHosting = with pkgs; with beamPackages;
          let mixDeps = import ./web/hosting/deps.nix { inherit lib beamPackages; };
          in
          mixRelease {
            __noChroot = true;
            pname = "hosting";
            src = ./web/hosting;
            version = version;
            mixNixDeps = mixDeps;
            preConfigure = ''
              js_files="$(find ${builtins.concatStringsSep " " (builtins.attrValues mixDeps)} -name '*.js')"
              mkdir deps
              cp $js_files deps/
              HEX_OFFLINE= mix do deps.get, assets.deploy
            '';
          };

        dockerImageHosting = pkgs.dockerTools.buildImage
          {
            name = "codesupplydocker/hosting";
            tag = version;
            config = {
              Cmd = [ "${buildHosting}/bin/hosting" "start" ];
              Env = [ "PATH=/bin:$PATH" "LC_ALL=C.UTF-8" ];
            };
            copyToRoot = pkgs.buildEnv {
              name = "image-root";
              paths = with pkgs; [
                bash
                coreutils
                gnugrep
                gnused
              ];
              pathsToLink = [ "/bin" ];
            };
          };

        devShell = with pkgs;
          mkShell {
            packages = [
              dnsmasq
              elixir
              elixir_ls
              inotify-tools
              jq
              kubectl
              kustomize
              kustomize
              mix2nix
              nodePackages."@tailwindcss/language-server"
              nodePackages.typescript
              nodePackages.typescript-language-server
              postgresql_15
              shellcheck
              terraform
              terraform-lsp
            ];
            shellHook = ''
              [ ! -e .postgres ] && bin/postgres-start
              export PGHOST="$PWD/.postgres"
              createuser hosting --createdb
              if ! pgrep dnsmasq
              then
                sudo dnsmasq --server='/*/8.8.8.8' --address='/*.code.test/127.0.0.1' --address '/*.code.supply/81.187.237.24'
              fi
            '';
          }
        ;
      in
      {
        packages = {
          hosting = buildHosting;
          docker = dockerImageHosting;
        };
        defaultPackage = buildHosting;
        devShells.default = devShell;
      }
    );
}
