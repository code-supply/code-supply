{
  pkgs,
  mkShell,
}:

mkShell {
  packages = with pkgs; [
    (writeShellApplication {
      name = "extract-ed25519-pub-key";
      text = ''
        ssh-keygen -i -D ${yubico-piv-tool}/lib/libykcs11.so -m PKCS8 -f my-pub-key.pem
      '';
    })
    elixir
    elixir-ls
    flashprog
    google-cloud-sdk
    inotify-tools
    jq
    opentofu
    shellcheck
    terraform-lsp
    zola
  ];
}
