{ pkgs
, mkShell
, elixir
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
    ++ [ elixir postgresql ]
    ++ extraPackages;
  shellHook = ''
    export PGHOST="$(git rev-parse --show-toplevel)/.postgres"
  '';
}
