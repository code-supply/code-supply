{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    nix = {
      url = "nix/2.20.1";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-mob = {
      url = "github:code-supply/rusty-git-mob";
      # url = "/home/andrew/workspace/rusty-git-mob";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nix, nixpkgs, home-manager, git-mob }:
    let
      system = "x86_64-linux";
      version =
        if self ? rev
        then self.rev
        else "dirty";

      pkgs = nixpkgs.legacyPackages.${system};

      callBox = name: import ./boxes/${name} {
        inherit nixpkgs system;
        nix = nix.packages.${system}.nix;
        websites = {
          inherit andrewbruce codesupply;
        };
      };

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

      homeConfigurations.andrew = import ./home-manager {
        inherit home-manager pkgs git-mob;
      };

      nixosModules = {
        kitty = import ./home-manager/kitty.nix;
      };

      nixosConfigurations = {
        fatty = callBox "fatty";
        p14s = callBox "p14s";
        unhinged = callBox "unhinged";
      };
    };
}
