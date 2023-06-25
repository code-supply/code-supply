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
        version = nixpkgs.lib.strings.removeSuffix "\n" (builtins.readFile ./web/hosting/VERSION);
        postgresStart = with pkgs;
          writeShellScriptBin "postgres-start" ''
            [[ -d "$PROJECT_ROOT/.postgres" ]] || ${postgresql_15}/bin/initdb -D "$PROJECT_ROOT/.postgres/db"
            ${postgresql_15}/bin/pg_ctl \
              -D "$PROJECT_ROOT/.postgres/db" \
              -l "$PROJECT_ROOT/.postgres/log" \
              -o "--unix_socket_directories='$PROJECT_ROOT/.postgres'" \
              -o "--listen_addresses=" \
              start
          '';

        devShell = with pkgs;
          mkShell {
            packages = [
              dnsmasq
              elixir
              elixir_ls
              google-cloud-sdk
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
              postgresStart
              shellcheck
              terraform
              terraform-lsp
            ];
            shellHook = ''
              export PROJECT_ROOT="$(git rev-parse --show-toplevel)"
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
        devShells.default = devShell;
      }
    );
}
