{
  pkgs,
  mkShell,
}:

mkShell {
  packages = with pkgs; [
    elixir
    elixir_ls
    google-cloud-sdk
    inotify-tools
    jq
    opentofu
    shellcheck
    terraform-lsp
    zola
  ];
}
