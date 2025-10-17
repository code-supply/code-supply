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
    isd = {
      url = "github:isd-project/isd";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    klix = {
      url = "github:code-supply/klix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi/main";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    builders = "ssh://klix.code.supply aarch64-linux - 15 - kvm,nixos-test,big-parallel";
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
      isd,
      klix,
      nixos-raspberrypi,
      nixpkgs,
      nixvim,
    }@inputs:
    let
      system = "x86_64-linux";
      version = if self ? rev then self.rev else "dirty";

      pkgs = import nixpkgs {
        inherit system;
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
              isd
              nixpkgs
              sops-nix
              system
              ;
            nix = pkgs.nixVersions.nix_2_30;
            websites = {
              inherit andrewbruce codesupply;
              klix = klix.packages.aarch64-linux.default;
            };
            klixUrl = klix.packages.aarch64-linux.url;
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

      packages.aarch64-linux.rp5SDCard =
        let
          installer = nixos-raspberrypi.lib.nixosInstaller {
            specialArgs = inputs;
            modules = [
              nixos-raspberrypi.inputs.nixos-images.nixosModules.sdimage-installer
              nixos-raspberrypi.nixosModules.raspberry-pi-5.base
              nixos-raspberrypi.nixosModules.raspberry-pi-5.page-size-16k

              (
                {
                  config,
                  lib,
                  modulesPath,
                  ...
                }:
                {
                  disabledModules = [
                    # disable the sd-image module that nixos-images uses
                    (modulesPath + "/installer/sd-card/sd-image-aarch64-installer.nix")
                  ];
                  # nixos-images sets this with `mkForce`, thus `mkOverride 40`
                  image.baseName =
                    let
                      cfg = config.boot.loader.raspberryPi;
                    in
                    lib.mkOverride 40 "nixos-installer-rpi${cfg.variant}-${cfg.bootloader}";
                  networking.hostName = "rp5";
                  users.users.root.openssh.authorizedKeys.keys = [
                    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCvEdU8Vs+25y3uN6YTFqNPKGdr7Z+v6lhuMQ0ppJ33pWPUh/AMMtumEr1Jb6+oAN7q4fozbu6o+9U1BlD0VXeIIAKaekru0tFzhcrvfQO8oiLs4f2TaQW8w5aprjmK8k5ZWdD2PV03jzxXnMhmFANr+zPgxLgy+J9JkoQJUcDBic1C1nbXLgHl7D0027aBT1NBGtK8ildCiDHmEh8qlCVJI6CSCS6fesZiHiyuEIVF1BG/DR9PWganyyuCHEav11fmiWiJAMUfCNwWosEoT4w0CTJ3vIhqeF9uAilo/NdUBGWJF/hLjWVFVoJ8uYjQyA70d0PY6mZjJgv+MUxsJoxYY1mQ+QqoIp3gF2/XAX1LwZPgd3Qh+cO2hkvBQ82g2TXqzu3bTSr/Gf4lUSmGPsozFhvkuRLL78wLefpY333NJ+ysp2XMwDDH0LEdQxeRbjlItpE7yEADiwe92RvsxxWgTFpHzMbxGaC95B0ZA2PUjY1izJQMPvGkV/4mx3QtC8wW/KeJJ52aWEO/Lcaec69bkKh56bOekipu6Jgs30e7CPtcgnMfllZRYbXvv05MlSKSTycgEMVssmjGEpKtVfIJiQUAhML4tQxfhZqy2t1/61tO2FgLDytoxLojQzJz9VOlsGcK7butCSJx3wrgCvU2Yc5fD3mskFJUJO+jFFqyMQ== cardno:16_019_463"
                  ];
                }
              )
            ];
          };
        in
        installer.config.system.build.sdImage;

      devShells.${system}.default = devShell;

      homeConfigurations."andrew@fatty" = import ./home-manager/fatty.nix {
        inherit
          sops-nix
          home-manager
          nixvim
          pkgs
          git-mob
          ;
      };

      homeConfigurations."andrew@p14s" = import ./home-manager {
        inherit
          sops-nix
          home-manager
          nixvim
          pkgs
          git-mob
          catppuccin
          ;
      };

      nixosConfigurations = {
        fatty = callBox "fatty" pkgs;
        klix = callBox "klix" armPkgs;
        p14s = callBox "p14s" pkgs;
        unhinged = callBox "unhinged" pkgs;
        x200 = callBox "x200" pkgs;

        ketchup-king = nixpkgs.lib.nixosSystem (
          import ./boxes/ketchup-king {
            inherit
              isd
              klix
              nixpkgs
              ;
          }
        );

        rp5 = nixos-raspberrypi.lib.nixosSystem {
          modules = [
            {
              imports = with nixos-raspberrypi.nixosModules; [
                raspberry-pi-5.base
                raspberry-pi-5.page-size-16k
              ];
            }

            { networking.hostName = "rp5"; }
          ];
        };
      };

      templates.elixir = {
        description = "A starter flake for Elixir projects";
        path = flake-templates/elixir;
      };
    };
}
