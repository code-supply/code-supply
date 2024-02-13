{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      version =
        if self ? rev
        then self.rev
        else "dirty";

      pkgs = nixpkgs.legacyPackages.${system};

      common =
        let
          postgresql = pkgs.postgresql_15;
        in
        {
          inherit
            postgresql
            version
            ;
        };

      callPackage = pkgs.lib.callPackageWith (pkgs // common);

      andrewbruce = callPackage ./web/andrewbruce { };
      codesupply = callPackage ./web/code-supply { };

      devShell = callPackage ./nix/shell.nix {
        extraPackages = [
          (callPackage ./nix/dnsmasq-start.nix { })
          (callPackage ./nix/postgres-start.nix { })
          (callPackage ./nix/postgres-stop.nix { })
        ];
      };
    in
    {
      formatter.${system} = pkgs.nixpkgs-fmt;

      packages.${system} = {
        inherit
          andrewbruce
          codesupply
          ;

        default = andrewbruce;
      };

      devShells.${system}.default = devShell;
    };
}
