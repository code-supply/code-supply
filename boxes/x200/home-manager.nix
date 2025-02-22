{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.andrew = import ../../home-manager/x200.nix;
  };
}
