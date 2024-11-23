{
  pkgs,
  mkShell,
}:

mkShell {
  packages = with pkgs; [
    elixir_1_17
    (elixir_ls.override { elixir = elixir_1_17; })
    google-cloud-sdk
    inotify-tools
    jq
    opentofu
    shellcheck
    terraform-lsp
    zola
  ];
}
