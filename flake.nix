{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    phoenix-utils.url = "/home/andrew/workspace/phoenix-utils";
  };

  outputs = {
    self,
    nixpkgs,
    phoenix-utils,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    version =
      if self ? rev
      then self.rev
      else "dirty";

    hosting = phoenix-utils.lib.buildPhoenixApp {
      inherit pkgs system version;
      src = ./web/hosting;
      pname = "hosting";
      mix2NixOutput = ./web/hosting/deps.nix;
    };

    hostingDockerImage =
      pkgs.dockerTools.buildImage
      {
        name = "codesupplydocker/hosting";
        tag = version;
        config = {
          Cmd = ["${hosting.app}/bin/hosting" "start"];
          Env = ["PATH=/bin:$PATH" "LC_ALL=C.UTF-8"];
        };
        copyToRoot = pkgs.buildEnv {
          name = "image-root";
          paths = with pkgs; [
            bash
            coreutils
            gnugrep
            gnused
          ];
          pathsToLink = ["/bin"];
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

    hostingK8sManifests = pkgs.stdenv.mkDerivation {
      name = "code-supply-hosting-k8s";
      src = ./k8s/hosting;
      buildInputs = [
        pkgs.kustomize
      ];
      installPhase = ''
        kustomize edit set image hosting=${dockerImageFullName}
        mkdir $out
        kustomize build . > $out/manifest.yaml
      '';
    };

    hostingK8sScript = verb:
      pkgs.writeShellApplication {
        name = "hosting-k8s-diff";
        runtimeInputs = [
          pkgs.kubectl
          hostingK8sManifests
        ];
        text = "kubectl ${verb} -f ${hostingK8sManifests}/manifest.yaml";
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

    devShell = with pkgs;
      mkShell {
        packages = [
          dnsmasq
          dnsmasqStart
          elixir_ls
          google-cloud-sdk
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
          postgresStart
          postgresStop
          shellcheck
          terraform
          terraform-lsp
          hosting.elixir
        ];
        shellHook = ''
          export PGHOST="$(git rev-parse --show-toplevel)/.postgres"
        '';
      };
  in {
    packages.${system} = {
      inherit hostingDockerImage hostingK8sManifests hostingDockerPush;
      hostingK8sDiff = hostingK8sScript "diff";
      hostingK8sApply = hostingK8sScript "apply";
      default = hosting.app;
    };
    devShells.${system}.default = devShell;
  };
}
