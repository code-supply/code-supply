{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";
    phoenix-utils.url = "/home/andrew/workspace/phoenix-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    phoenix-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        version =
          if self ? rev
          then self.rev
          else "dirty";

        webApp = phoenix-utils.lib.buildPhoenixApp {
          inherit pkgs system version;
          src = ./web/hosting;
          pname = "code-supply-hosting";
          mixDepsSha256 = "sha256-BPuN5Ss6SeXPCQ/zh2SldIpxIry/zi3YYgKYPHnPRd0=";
        };

        dockerImage =
          pkgs.dockerTools.buildImage
          {
            name = "codesupplydocker/hosting";
            tag = version;
            config = {
              Cmd = ["${webApp.app}/bin/hosting start"];
              Env = ["PATH=/bin:$PATH" "LC_ALL=C.UTF-8"];
            };
            copyToRoot = pkgs.buildEnv {
              name = "image-root";
              paths = with pkgs; [
                bash
                coreutils
                gnugrep
                gnused
              ];
              pathsToLink = ["/bin"];
            };
          };

        webAppK8sManifests = pkgs.stdenv.mkDerivation {
          name = "code-supply-hosting-k8s";
          src = ./k8s/hosting;
          buildInputs = [
            pkgs.kustomize
          ];
          installPhase = with dockerImage; ''
            kustomize edit set image hosting=${imageName}:${imageTag}
            mkdir $out
            kustomize build . > $out/manifest.yaml
          '';
        };

        dnsmasqStart = with pkgs;
          writeShellScriptBin "dnsmasq-start" ''
            sudo dnsmasq \
              --server='/*/8.8.8.8' \
              --address='/*.code.test/127.0.0.1' \
              --address '/*.code.supply/81.187.237.24'
          '';

        postgresStart = with pkgs;
          writeShellScriptBin "postgres-start" ''
            [[ -d "$PGHOST" ]] || \
              ${postgresql_15}/bin/initdb -D "$PGHOST/db"
            ${postgresql_15}/bin/pg_ctl \
              -D "$PGHOST/db" \
              -l "$PGHOST/log" \
              -o "--unix_socket_directories='$PGHOST'" \
              -o "--listen_addresses=" \
              start
          '';
        postgresStop = with pkgs;
          writeShellScriptBin "postgres-stop" ''
            pg_ctl \
              -D "$PGHOST/db" \
              -l "$PGHOST/log" \
              -o "--unix_socket_directories=$PGHOST" \
              stop
          '';

        devShell = with pkgs;
          mkShell {
            packages = [
              dnsmasq
              dnsmasqStart
              elixir_ls
              google-cloud-sdk
              inotify-tools
              jq
              kubectl
              kustomize
              kustomize
              webApp.elixir
              mix2nix
              nodePackages."@tailwindcss/language-server"
              nodePackages.typescript
              nodePackages.typescript-language-server
              postgresql_15
              postgresStart
              postgresStop
              shellcheck
              terraform
              terraform-lsp
            ];
            shellHook = ''
              export PGHOST="$(git rev-parse --show-toplevel)/.postgres"
            '';
          };
      in {
        packages = {
          inherit dockerImage webAppK8sManifests;
          default = webApp.app;
        };
        devShells.default = devShell;
      }
    );
}
