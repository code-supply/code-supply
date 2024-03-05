{
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes repl-flake auto-allocate-uids
      keep-derivations = true
      keep-outputs = true
    '';
    settings = {
      trusted-users = [ "andrew" ];
      substituters = [ "https://nixos-homepage.cachix.org" ];
      trusted-public-keys = [ "nixos-homepage.cachix.org-1:NHKBt7NjLcWfgkX4OR72q7LVldKJe/JOsfIWFDAn/tE=" ];
    };
  };
}
