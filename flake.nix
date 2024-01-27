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
          elixir = beamPackages.elixir_1_16;
          postgresql = pkgs.postgresql_15;
        in
        {
          inherit
            beamPackages
            elixir
            hostingDockerImage
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

      hosting = callPackage ./web/hosting {
        mixNixDeps = callPackages ./web/hosting/deps.nix { };
      };
      hostingDockerImage = callPackage ./web/hosting/docker.nix { inherit hosting; };
      hostingDockerPush = callPackage ./nix/docker-push.nix { image = hostingDockerImage; };
      hostingK8sManifests = callPackage ./web/hosting/k8s { };

      tlsLbOperator = callPackage ./operators/tls-lb-operator {
        mixNixDeps = callPackages ./operators/tls-lb-operator/deps.nix { };
      };
      tlsLbOperatorDockerImage = callPackage ./operators/tls-lb-operator/docker.nix { inherit tlsLbOperator; };

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
          tlsLbOperatorDockerImage
          ;

        k8sDiff = callPackage ./nix/make-k8s-script.nix {
          verb = "diff";
          manifests = hostingK8sManifests;
        };

        k8sApply = callPackage ./nix/make-k8s-script.nix {
          verb = "apply";
          manifests = hostingK8sManifests;
        };

        default = hosting;
      };
      devShells.${system}.default = devShell;
    };
}
