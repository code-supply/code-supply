{
  pkgs,
  mkShell,
}:

mkShell {
  packages = with pkgs; [
    elixir
    elixir_ls
    flashprog
    google-cloud-sdk
    inotify-tools
    jq
    opentofu
    shellcheck
    terraform-lsp
    zola
  ];
}
