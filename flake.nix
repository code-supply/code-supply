{
  inputs = {
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    klix = {
      url = "github:code-supply/klix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  outputs =
    {
      self,
      sops-nix,
      catppuccin,
      home-manager,
      klix,
      nixpkgs,
      nixvim,
    }:
    let
      version = if self ? rev then self.rev else "dirty";

      x86Pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      armPkgs = import nixpkgs {
        system = "aarch64-linux";
      };

      callBox =
        name: pkgs:
        nixpkgs.lib.nixosSystem (
          import ./boxes/${name} {
            inherit
              home-manager
              nixpkgs
              sops-nix
              ;
            system = pkgs.stdenv.hostPlatform.system;
            nix = pkgs.nixVersions.nix_2_30;
            websites = {
              inherit andrewbruce codesupply;
              klix = klix.packages.aarch64-linux.web;
            };
            klixUrl = klix.packages.aarch64-linux.url;
          }
        );

      common = {
        inherit version;
      };

      x86CallPackage = x86Pkgs.lib.callPackageWith (x86Pkgs // common);
      armCallPackage = armPkgs.lib.callPackageWith (armPkgs // common);

      andrewbruce = armCallPackage ./web/andrewbruce { };
      codesupply = armCallPackage ./web/code-supply { };
      devShell = x86CallPackage ./shell.nix { };
    in
    {
      formatter.x86_64-linux = x86Pkgs.nixfmt;

      packages.aarch64-linux.ketchupKingSDCard =
        self.nixosConfigurations.ketchup-king.config.system.build.sdImage;

      devShells.x86_64-linux.default = devShell;

      homeConfigurations."andrew@fatty" = import ./home-manager/fatty.nix {
        inherit
          sops-nix
          home-manager
          nixvim
          ;
        pkgs = x86Pkgs;
      };

      homeConfigurations."andrew@p14s" = import ./home-manager {
        inherit
          sops-nix
          home-manager
          nixvim
          catppuccin
          ;
        pkgs = x86Pkgs;
      };

      nixosConfigurations = {
        fatty = callBox "fatty" x86Pkgs;
        klix = callBox "klix" armPkgs;
        p14s = callBox "p14s" x86Pkgs;
        unhinged = callBox "unhinged" x86Pkgs;
        x200 = callBox "x200" x86Pkgs;

        ketchup-king = klix.lib.nixosSystem (
          import ./boxes/ketchup-king {
            inherit klix;
          }
        );
      };

      templates.elixir = {
        description = "A starter flake for Elixir projects";
        path = flake-templates/elixir;
      };
    };
}
