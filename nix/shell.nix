{ pkgs
, mkShell
, elixir
, erlang
, postgresql
, extraPackages
}:
mkShell {
  packages =
    (with pkgs; [
      (elixir_ls.override { inherit elixir; })
      google-cloud-sdk
      nixpkgs-fmt
      inotify-tools
      jq
      kubectl
      kustomize
      mix2nix
      nodePackages."@tailwindcss/language-server"
      nodePackages.typescript
      nodePackages.typescript-language-server
      shellcheck
      terraform
      terraform-lsp
    ])
    ++ [ elixir erlang postgresql ]
    ++ extraPackages;
  shellHook = ''
    export PGHOST="$(git rev-parse --show-toplevel)/.postgres"
  '';
}
