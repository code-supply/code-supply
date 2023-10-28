{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    kubenix.url = "github:hall/kubenix";
  };

  outputs = { self, nixpkgs, kubenix }:
    let
      system = "x86_64-linux";
      version =
        if self ? rev
        then self.rev
        else "dirty";

      pkgs = nixpkgs.legacyPackages.${system};

      common =
        let
          beamPackages = with pkgs.beam_minimal; packagesWith interpreters.erlangR26;
          elixir = beamPackages.elixir_1_15;
          postgresql = pkgs.postgresql_15;
        in
        {
          inherit
            beamPackages
            elixir
            hostingDockerImage
            hostingK8sManifests
            kubenix
            postgresql
            version
            ;

          erlang = beamPackages.erlang;
          hex = beamPackages.hex.override { inherit elixir; };

          mixRelease =
            beamPackages.mixRelease.override {
              inherit elixir;
              fetchMixDeps = beamPackages.fetchMixDeps.override { inherit elixir; };
            };
        };

      callPackage = pkgs.lib.callPackageWith (pkgs // common);
      callPackages = pkgs.lib.callPackagesWith (pkgs // common);

      hosting = callPackage ./web/hosting/default.nix {
        mixNixDeps = callPackages ./web/hosting/deps.nix { };
      };
      hostingDockerImage = callPackage ./web/hosting/docker.nix { inherit hosting; };
      hostingDockerPush = callPackage ./web/hosting/docker-push.nix { };
      hostingK8sManifests = callPackage ./web/hosting/k8s.nix { };

      tlsLbOperator = callPackage ./operators/tls-lb-operator/default.nix {
        mixNixDeps = callPackages ./operators/tls-lb-operator/deps.nix { };
      };

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
          hostingDockerImage
          hostingK8sManifests
          hostingDockerPush

          tlsLbOperator
          ;
        hostingK8sDiff = callPackage ./web/hosting/make-k8s-script.nix { verb = "diff"; };
        hostingK8sApply = callPackage ./web/hosting/make-k8s-script.nix { verb = "apply"; };
        default = hosting;
      };
      devShells.${system}.default = devShell;
    };
}
