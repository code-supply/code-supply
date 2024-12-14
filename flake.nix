{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-mob = {
      url = "github:code-supply/rusty-git-mob";
      # url = "/home/andrew/workspace/rusty-git-mob";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixvim,
      git-mob,
      catppuccin,
    }:
    let
      system = "x86_64-linux";
      version = if self ? rev then self.rev else "dirty";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      callBox =
        name:
        nixpkgs.lib.nixosSystem (
          import ./boxes/${name} {
            inherit nixpkgs system;
            nix = nixpkgs.legacyPackages.${system}.nixVersions.nix_2_24;
            websites = {
              inherit andrewbruce codesupply;
            };
          }
        );

      common = {
        inherit version;
      };

      callPackage = pkgs.lib.callPackageWith (pkgs // common);

      andrewbruce = callPackage ./web/andrewbruce { };
      codesupply = callPackage ./web/code-supply { };
      devShell = callPackage ./shell.nix { };
    in
    {
      formatter.${system} = pkgs.nixfmt-rfc-style;

      packages.${system} = {
        inherit
          andrewbruce
          codesupply
          ;

        default = andrewbruce;
      };

      devShells.${system}.default = devShell;

      homeConfigurations."andrew@fatty" = import ./home-manager/fatty.nix {
        inherit home-manager pkgs git-mob;
      };

      homeConfigurations."andrew@p14s" = import ./home-manager {
        inherit
          home-manager
          nixvim
          pkgs
          git-mob
          catppuccin
          ;
      };

      nixosModules = {
        kitty = import ./home-manager/kitty.nix;
      };

      nixosConfigurations = {
        fatty = callBox "fatty";
        p14s = callBox "p14s";
        unhinged = callBox "unhinged";
      };

      templates.elixir = {
        path = flake-templates/elixir;
      };
    };
}
