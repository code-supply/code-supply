{ pkgs
, mkShell

, cmake
, elixir
, erlang
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
      elixir_ls
      google-cloud-sdk
      inotify-tools
      jq
      kubectl
      kustomize
      mix2nix
      nixpkgs-fmt
      nodePackages."@tailwindcss/language-server"
      nodePackages.typescript
      nodePackages.typescript-language-server
      opentofu
      shellcheck
      terraform-lsp
      zola
    ] ++ rustPkgs)
    ++ [ elixir erlang postgresql ]
    ++ extraPackages;
  shellHook = ''
    export PGHOST="$(git rev-parse --show-toplevel)/.postgres"
  '';
}
