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

      hosting = import ./web/hosting/default.nix {
        inherit pkgs beamPackages version;

        src = ./web/hosting;
        pname = "hosting";
        extractVersion = "${elixir}/bin/elixir ${self}/nix/extract_version.ex";

        mixRelease =
          beamPackages.mixRelease.override {
            inherit elixir;
            fetchMixDeps = beamPackages.fetchMixDeps.override { inherit elixir; };
            erlang = beamPackages.erlang;
          };
      };

      hostingDockerImage =
        pkgs.dockerTools.buildImage
          {
            name = "codesupplydocker/hosting";
            tag = version;
            config = {
              Cmd = [ "server" ];
              Env = [ "LC_ALL=C.UTF-8" ];
            };
            copyToRoot = pkgs.buildEnv {
              name = "image-root";
              paths = [
                hosting
                pkgs.busybox
              ];
              pathsToLink = [ "/bin" ];
            };
          };

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

      hostingK8sScript = verb:
        pkgs.writeShellApplication {
          name = "hosting-k8s-${verb}";
          runtimeInputs = [
            pkgs.kubectl
            hostingK8sManifests
          ];
          text = "kubectl ${verb} -f ${hostingK8sManifests}";
        };

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
            elixir_ls
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
        hostingK8sDiff = hostingK8sScript "diff";
        hostingK8sApply = hostingK8sScript "apply";
        default = hosting;
      };
      devShells.${system}.default = devShell;
    };
}
