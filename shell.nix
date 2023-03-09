with import <nixpkgs> { };

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
    terraform
    terraform-lsp
  ];
  shellHook = ''
    initdb -D .postgres/db
    pg_ctl -D .postgres/db -l .postgres/log -o "--unix_socket_directories='$PWD/.postgres'" start
    export PGHOST="$PWD/.postgres"
    createuser affable --createdb
    if ! pgrep dnsmasq
    then
      sudo dnsmasq --server='/*/8.8.8.8' --address='/*.affable.test/127.0.0.1'
    fi
  '';
}
