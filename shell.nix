with import <nixpkgs> { };

mkShell {
  packages = [
    elixir_1_14
    elixir_ls
    inotify-tools
    jq
    kubectl
    kustomize
    nodePackages."@tailwindcss/language-server"
    postgresql_15
    terraform
    terraform-lsp
  ];
  shellHook = ''
    initdb -D .postgres/db
    pg_ctl -D .postgres/db -l .postgres/log -o "--unix_socket_directories='$PWD/.postgres'" start
    export PGHOST="$PWD/.postgres"
    createuser affable --createdb
  '';
}
