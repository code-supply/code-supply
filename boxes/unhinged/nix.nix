{
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      require-sigs = false
    '';
  };
}
