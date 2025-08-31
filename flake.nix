{
  inputs = {
    catppuccin.url = "github:catppuccin/nix";
    git-mob = {
      url = "github:code-supply/rusty-git-mob";
      # url = "/home/andrew/workspace/rusty-git-mob";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    isd = {
      url = "github:isd-project/isd";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    klix = {
      url = "github:code-supply/klix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      catppuccin,
      git-mob,
      home-manager,
      isd,
      klix,
      nixpkgs,
      nixvim,
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
            inherit
              home-manager
              nixpkgs
              system
              ;
            nix = pkgs.nixVersions.nix_2_30;
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

      packages.aarch64-linux.ketchupKingSDCard =
        self.nixosConfigurations.ketchup-king.config.system.build.sdImage;

      devShells.${system}.default = devShell;

      homeConfigurations."andrew@fatty" = import ./home-manager/fatty.nix {
        inherit
          home-manager
          nixvim
          pkgs
          git-mob
          ;
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

      nixosConfigurations = {
        fatty = callBox "fatty";
        p14s = callBox "p14s";
        unhinged = callBox "unhinged";
        x200 = callBox "x200";

        ketchup-king = nixpkgs.lib.nixosSystem (
          import ./boxes/ketchup-king {
            inherit
              isd
              klix
              nixpkgs
              ;
          }
        );
      };

      templates.elixir = {
        description = "A starter flake for Elixir projects";
        path = flake-templates/elixir;
      };
    };
}
