{ pkgs
, mkShell

, cmake
, postgresql

, extraPackages
}:
mkShell {
  packages =
    (with pkgs; let
      rustPkgs = [
        cargo
        openssl
        pkg-config
        rust-analyzer
        rustc
        rustfmt
      ];
    in
    [
      cmake
      google-cloud-sdk
      inotify-tools
      jq
      nixpkgs-fmt
      opentofu
      postgresql
      shellcheck
      terraform-lsp
      zola
    ] ++ rustPkgs)
    ++ extraPackages;
  shellHook = ''
    export PGHOST="$(git rev-parse --show-toplevel)/.postgres"
  '';
}
