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
        version = nixpkgs.lib.strings.removeSuffix "\n" (builtins.readFile ./web/hosting/VERSION);

        esbuildBinary = pkgs.stdenv.mkDerivation {
          name = "esbuildbinary";
          src = pkgs.fetchzip {
            url = "https://registry.npmjs.org/esbuild-linux-64/-/esbuild-linux-64-0.14.41.tgz";
            sha256 = "sha256-0UHSZspwruv+87yfJJyySqVm28iPA5WI4PyAeL03Cfg=";
          };
          installPhase = ''
            mkdir -p $out/bin
            cp $src/bin/esbuild $out/bin/
          '';
        };

        tailwindBinary = pkgs.stdenv.mkDerivation {
          name = "tailwindbinary";
          src = pkgs.fetchurl {
            url = "https://github.com/tailwindlabs/tailwindcss/releases/download/v3.1.4/tailwindcss-linux-x64";
            sha256 = "sha256-3aw8TZ1dpsvziSPYeu89QKO/iciGIAtvEAu/j8GdWm8=";
          };
          dontUnpack = true;
          dontStrip = true;
          installPhase = "install -m755 -D $src $out/bin/tailwindcss-linux-x64";
        };

        buildHosting = with pkgs; with beamPackages;
          let
            mixDeps = import ./web/hosting/deps.nix { inherit lib beamPackages; };
          in

          mixRelease {
            pname = "hosting";
            src = ./web/hosting;
            version = version;
            buildInputs = [ esbuildBinary tailwindBinary ];
            mixNixDeps = mixDeps;
            preConfigure = ''
              js_files="$(find ${builtins.concatStringsSep " " (builtins.attrValues mixDeps)} -name '*.js')"
              mkdir deps
              cp $js_files deps/

              (
              cd assets
              ${tailwindBinary}/bin/tailwindcss-linux-x64 \
                --config=tailwind.config.js \
                --input=css/app.css \
                --output=../priv/static/assets/app.css \
                --minify
              )

              (
              cd assets
              export NODE_PATH=../deps
              ${esbuildBinary}/bin/esbuild \
                src/app.ts \
                --bundle \
                --target=es2017 \
                --outdir=../priv/static/assets \
                --external:/fonts/* \
                --external:/images/* \
                --minify
              )

              cp -a assets/static/* priv/static/
            '';
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
              esbuildBinary
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
              tailwindBinary
              terraform
              terraform-lsp
            ];
            shellHook = ''
              export MIX_ESBUILD_PATH=${esbuildBinary}/bin/esbuild
              export MIX_TAILWIND_PATH=${tailwindBinary}/bin/tailwindcss-linux-x64

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
