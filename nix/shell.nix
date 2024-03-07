{ pkgs
, mkShell
, cmake
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
      shellcheck
      terraform-lsp
      zola
    ] ++ rustPkgs);
}
