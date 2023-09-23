{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    kubenix.url = "github:hall/kubenix";
  };

  outputs = { self, nixpkgs, kubenix }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      version =
        if self ? rev
        then self.rev
        else "dirty";

      beamPackages = with pkgs.beam_minimal; packagesWith interpreters.erlangR26;
      elixir = beamPackages.elixir_1_15;

      callPackage = pkgs.lib.callPackageWith (pkgs // packages);
      callPackages = pkgs.lib.callPackagesWith (pkgs // packages);
      packages = { inherit beamPackages elixir version hostingK8sManifests; };

      hosting = callPackage ./web/hosting/default.nix {
        mixRelease =
          beamPackages.mixRelease.override {
            inherit elixir;
            fetchMixDeps = beamPackages.fetchMixDeps.override { inherit elixir; };
          };
        mixNixDeps = callPackages ./web/hosting/deps.nix { };
      };

      hostingDockerImage = callPackage ./web/hosting/docker.nix { inherit hosting; };

      dockerImageFullName = with hostingDockerImage; "${imageName}:${imageTag}";

      hostingDockerPush = pkgs.writeShellApplication {
        name = "hosting-docker-push";
        text =
          if hostingDockerImage.imageTag == "dirty"
          then ''echo "Commit first!"; exit 1''
          else ''
            docker load < ${hostingDockerImage}
            docker push ${dockerImageFullName}
          '';
      };

      hostingK8sManifests = (kubenix.evalModules.${system} (
        (import ./web/hosting/k8s.nix) {
          inherit pkgs dockerImageFullName;
        })).config.kubernetes.result;

      dnsmasqStart = with pkgs;
        writeShellScriptBin "dnsmasq-start" ''
          sudo dnsmasq \
            --server='/*/8.8.8.8' \
            --address='/*.code.test/127.0.0.1' \
            --address '/*.code.supply/81.187.237.24'
        '';

      postgresStart = with pkgs;
        writeShellScriptBin "postgres-start" ''
          [[ -d "$PGHOST" ]] || \
            ${postgresql_15}/bin/initdb -D "$PGHOST/db"
          ${postgresql_15}/bin/pg_ctl \
            -D "$PGHOST/db" \
            -l "$PGHOST/log" \
            -o "--unix_socket_directories='$PGHOST'" \
            -o "--listen_addresses=" \
            start
        '';
      postgresStop = with pkgs;
        writeShellScriptBin "postgres-stop" ''
          pg_ctl \
            -D "$PGHOST/db" \
            -l "$PGHOST/log" \
            -o "--unix_socket_directories=$PGHOST" \
            stop
        '';

      devShell = pkgs.mkShell {
        packages =
          [
            dnsmasqStart
            elixir
            postgresStart
            postgresStop
          ]
          ++ (with pkgs; [
            dnsmasq
            (elixir_ls.override { inherit elixir; })
            google-cloud-sdk
            nixpkgs-fmt
            inotify-tools
            jq
            kubectl
            kustomize
            kustomize
            mix2nix
            nodePackages."@tailwindcss/language-server"
            nodePackages.typescript
            nodePackages.typescript-language-server
            postgresql_15
            shellcheck
            terraform
            terraform-lsp
          ]);
        shellHook = ''
          export PGHOST="$(git rev-parse --show-toplevel)/.postgres"
        '';
      };
    in
    {
      formatter.${system} = pkgs.nixpkgs-fmt;
      packages.${system} = {
        inherit hostingDockerImage hostingK8sManifests hostingDockerPush;
        hostingK8sDiff = callPackage ./web/hosting/make-k8s-script.nix { verb = "diff"; };
        hostingK8sApply = callPackage ./web/hosting/make-k8s-script.nix { verb = "apply"; };
        default = hosting;
      };
      devShells.${system}.default = devShell;
    };
}
