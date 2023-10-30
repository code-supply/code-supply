{ pkgs
, mkShell
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
      ];
    in
    [
      (elixir_ls.override { inherit elixir; })
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
      shellcheck
      terraform
      terraform-lsp
    ] ++ rustPkgs)
    ++ [ elixir erlang postgresql ]
    ++ extraPackages;
  shellHook = ''
    export PGHOST="$(git rev-parse --show-toplevel)/.postgres"
  '';
}
