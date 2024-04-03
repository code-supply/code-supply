{ pkgs
, mkShell
}:

mkShell {
  packages = with pkgs;
    [
      inotify-tools
      jq
      nixpkgs-fmt
      opentofu
      shellcheck
      terraform-lsp
      zola
    ];
}
