{ pkgs }:

with pkgs;

mkShell {
  packages = [
    dnsmasq
    elixir_1_14
    elixir_ls
    inotify-tools
    jq
    kubectl
    kustomize
    nodePackages."@tailwindcss/language-server"
    nodePackages.typescript
    nodePackages.typescript-language-server
    postgresql_15
    shellcheck
    terraform
    terraform-lsp
  ];
  shellHook = ''
    initdb -D .postgres/db
    pg_ctl -D .postgres/db -l .postgres/log -o "--unix_socket_directories='$PWD/.postgres'" start
    export PGHOST="$PWD/.postgres"
    createuser hosting --createdb
    if ! pgrep dnsmasq
    then
      sudo dnsmasq --server='/*/8.8.8.8' --address='/*.code.test/127.0.0.1' --address '/*.code.supply/81.187.237.24'
    fi
  '';
}
