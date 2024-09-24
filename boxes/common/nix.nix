{
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes repl-flake auto-allocate-uids
      keep-derivations = true
      keep-outputs = true
    '';
    settings = {
      trusted-users = [ "andrew" ];
    };
  };
}
