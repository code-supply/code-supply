{ pkgs
, mkShell
}:

mkShell {
  packages = with pkgs;
    [
      google-cloud-sdk
      inotify-tools
      jq
      nixpkgs-fmt
      opentofu
      shellcheck
      terraform-lsp
      zola
    ];
}
