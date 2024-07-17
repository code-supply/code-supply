{
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      require-sigs = false
    '';
    settings.trusted-users = [
      "root"
      "@wheel"
    ];
  };
}
