{ pkgs
, mkShell
, elixir
, extraPackages
}:
mkShell {
  packages =
    (with pkgs; [
      dnsmasq
      (elixir_ls.override { inherit elixir; })
      google-cloud-sdk
      nixpkgs-fmt
      inotify-tools
      jq
      kubectl
      kustomize
      kustomize
      mix2nix
      nodePackages."@tailwindcss/language-server"
      nodePackages.typescript
      nodePackages.typescript-language-server
      postgresql_15
      shellcheck
      terraform
      terraform-lsp
    ]) ++ extraPackages;
  shellHook = ''
    export PGHOST="$(git rev-parse --show-toplevel)/.postgres"
  '';
}
