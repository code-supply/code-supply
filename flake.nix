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
        minimalElixir = beamPkgs.elixir_1_14;
        version = nixpkgs.lib.strings.removeSuffix "\n" (builtins.readFile ./web/hosting/VERSION);
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
              minimalElixir
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
          }
        ;
      in
      {
        devShells.default = devShell;
      }
    );
}
