{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    kubenix.url = "github:hall/kubenix";
  };

  outputs = {
    self,
    nixpkgs,
    kubenix,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    version =
      if self ? rev
      then self.rev
      else "dirty";

    beamPackages = with pkgs.beam_minimal; packagesWith interpreters.erlangR25;
    erlang = beamPackages.erlang;
    elixir = beamPackages.elixir_1_14;
    fetchMixDeps = beamPackages.fetchMixDeps.override {inherit elixir;};
    mixRelease = beamPackages.mixRelease.override {inherit elixir erlang fetchMixDeps;};
    src = ./web/hosting;
    tailwindPath = "_build/tailwind-linux-x64";
    esbuildPath = "_build/esbuild-linux-x64";

    pname = "hosting";

    hosting = mixRelease {
      inherit pname src version;

      meta.mainProgram = pname;

      stripDebug = true;

      mixNixDeps = (import ./web/hosting/deps.nix) {
        inherit beamPackages;
        lib = pkgs.lib;
        overrides = let
          overrideFun = old: {
            postInstall = ''
              cp -v package.json "$out/lib/erlang/lib/${old.name}"
            '';
          };
        in
          _: prev: {
            phoenix = prev.phoenix.overrideAttrs overrideFun;
            phoenix_html = prev.phoenix_html.overrideAttrs overrideFun;
            phoenix_live_view = prev.phoenix_live_view.overrideAttrs overrideFun;
          };
      };

      postUnpack = ''
        tailwind_version="$(${elixir}/bin/elixir ${self}/nix/extract_version.ex ${src}/config/config.exs tailwind)"
        esbuild_version="$(${elixir}/bin/elixir ${self}/nix/extract_version.ex ${src}/config/config.exs esbuild)"

        errors=0

        if [[ -z "$tailwind_version" ]]
        then
          echo "No Tailwind version found in config/config.exs - continuing without Tailwind."
        elif [[ "$tailwind_version" != "${pkgs.tailwindcss.version}" ]]
        then
          errors+=1
          echo "error: Tailwind version mismatch: using ${pkgs.tailwindcss.version} from nix but $tailwind_version in your app!"
        fi

        if [[ -z "$esbuild_version" ]]
        then
          echo "No esbuild version found in config/config.exs - continuing without esbuild."
        elif [[ "$esbuild_version" != "${pkgs.esbuild.version}" ]]
        then
          errors+=1
          echo "error: esbuild version mismatch: using ${pkgs.esbuild.version} from nix but $esbuild_version in your app!"
        fi

        if [[ "$errors" > 0 ]]
        then
          echo "Please fix the above errors and try again."
          exit 1
        fi
      '';

      preBuild = ''
        mkdir ./deps
        cp -a _build/prod/lib/. ./deps/
      '';

      postBuild = ''
        ln -sfv ${pkgs.tailwindcss}/bin/tailwindcss ${tailwindPath}
        ln -sfv ${pkgs.esbuild}/bin/esbuild ${esbuildPath}

        mix assets.deploy --no-deps-check
      '';
    };

    hostingDockerImage =
      pkgs.dockerTools.buildImage
      {
        name = "codesupplydocker/hosting";
        tag = version;
        config = {
          Cmd = ["${pkgs.lib.getExe hosting}" "start"];
          Env = ["PATH=/bin:$PATH" "LC_ALL=C.UTF-8"];
        };
        copyToRoot = pkgs.buildEnv {
          name = "image-root";
          paths = with pkgs; [
            busybox
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

    hostingK8sManifests =
      (kubenix.evalModules.${system} {
        module = {kubenix, ...}: {
          imports = [kubenix.modules.k8s];
          kubernetes = {
            namespace = "hosting";
            resources = {
              namespaces.hosting = {};
              deployments = {
                hosting = import ./k8s/hosting/deployment.nix {
                  lib = pkgs.lib;
                  image = dockerImageFullName;
                };
              };
            };
          };
        };
      })
      .config
      .kubernetes
      .result;

    hostingK8sScript = verb:
      pkgs.writeShellApplication {
        name = "hosting-k8s-diff";
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
  in {
    formatter.${system} = pkgs.alejandra;
    packages.${system} = {
      inherit hostingDockerImage hostingK8sManifests hostingDockerPush;
      hostingK8sDiff = hostingK8sScript "diff";
      hostingK8sApply = hostingK8sScript "apply";
      default = hosting;
    };
    devShells.${system}.default = devShell;
  };
}
