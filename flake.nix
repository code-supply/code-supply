{
  inputs = {
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
    };
    git-mob = {
      url = "github:code-supply/rusty-git-mob";
      # url = "/home/andrew/workspace/rusty-git-mob";
      inputs.nixpkgs.follows = "nixpkgs";
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
      git-mob,
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

      packages.aarch64-linux.rp5SDCard = self.nixosConfigurations.rp5.config.system.build.sdImage;

      devShells.x86_64-linux.default = devShell;

      homeConfigurations."andrew@fatty" = import ./home-manager/fatty.nix {
        inherit
          sops-nix
          home-manager
          nixvim
          git-mob
          ;
        pkgs = x86Pkgs;
      };

      homeConfigurations."andrew@p14s" = import ./home-manager {
        inherit
          sops-nix
          home-manager
          nixvim
          git-mob
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

        rp5 = klix.lib.nixosSystem {
          modules = [
            {
              imports = klix.lib.machineImports.raspberry-pi-5;

              networking.hostName = "rp5";
              users.users.root.openssh.authorizedKeys.keys = [
                "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCvEdU8Vs+25y3uN6YTFqNPKGdr7Z+v6lhuMQ0ppJ33pWPUh/AMMtumEr1Jb6+oAN7q4fozbu6o+9U1BlD0VXeIIAKaekru0tFzhcrvfQO8oiLs4f2TaQW8w5aprjmK8k5ZWdD2PV03jzxXnMhmFANr+zPgxLgy+J9JkoQJUcDBic1C1nbXLgHl7D0027aBT1NBGtK8ildCiDHmEh8qlCVJI6CSCS6fesZiHiyuEIVF1BG/DR9PWganyyuCHEav11fmiWiJAMUfCNwWosEoT4w0CTJ3vIhqeF9uAilo/NdUBGWJF/hLjWVFVoJ8uYjQyA70d0PY6mZjJgv+MUxsJoxYY1mQ+QqoIp3gF2/XAX1LwZPgd3Qh+cO2hkvBQ82g2TXqzu3bTSr/Gf4lUSmGPsozFhvkuRLL78wLefpY333NJ+ysp2XMwDDH0LEdQxeRbjlItpE7yEADiwe92RvsxxWgTFpHzMbxGaC95B0ZA2PUjY1izJQMPvGkV/4mx3QtC8wW/KeJJ52aWEO/Lcaec69bkKh56bOekipu6Jgs30e7CPtcgnMfllZRYbXvv05MlSKSTycgEMVssmjGEpKtVfIJiQUAhML4tQxfhZqy2t1/61tO2FgLDytoxLojQzJz9VOlsGcK7butCSJx3wrgCvU2Yc5fD3mskFJUJO+jFFqyMQ== cardno:16_019_463"
              ];

              services.klix = {
                configDir = ./boxes/ketchup-king/klipper;
              };

              services.klipper = {
                plugins = {
                  kamp.enable = true;
                  shaketune.enable = true;
                  z_calibration.enable = true;
                };
              };

              services.klipperscreen.enable = true;
            }
          ];
        };
      };

      templates.elixir = {
        description = "A starter flake for Elixir projects";
        path = flake-templates/elixir;
      };
    };
}
