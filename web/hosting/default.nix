{ lib
, beamPackages
, mixRelease
, version
, elixir
, tailwindcss
, esbuild
}:

let
  pname = "hosting";
  src = ./.;
  extractVersion = "${elixir}/bin/elixir ${../../nix/extract_version.ex}";
in
mixRelease {
  inherit pname src version;

  meta.mainProgram = pname;

  stripDebug = true;

  mixNixDeps = (import ./deps.nix) { inherit lib beamPackages; };

  postUnpack = ''
    tailwind_version="$(${extractVersion} ${src}/config/config.exs tailwind)"
    esbuild_version="$(${extractVersion} ${src}/config/config.exs esbuild)"

    errors=0

    if [[ -z "$tailwind_version" ]]
    then
      echo "No Tailwind version found in config/config.exs - continuing without Tailwind."
    elif [[ "$tailwind_version" != "${tailwindcss.version}" ]]
    then
      errors+=1
      echo "error: Tailwind version mismatch: using ${tailwindcss.version} from nix but $tailwind_version in your app!"
    fi

    if [[ -z "$esbuild_version" ]]
    then
      echo "No esbuild version found in config/config.exs - continuing without esbuild."
    elif [[ "$esbuild_version" != "${esbuild.version}" ]]
    then
      errors+=1
      echo "error: esbuild version mismatch: using ${esbuild.version} from nix but $esbuild_version in your app!"
    fi

    if [[ "$errors" > 0 ]]
    then
      echo "Please fix the above errors and try again."
      exit 1
    fi
  '';

  postBuild = ''
    ln -sfv ${tailwindcss}/bin/tailwindcss _build/tailwind-linux-x64
    ln -sfv ${esbuild}/bin/esbuild _build/esbuild-linux-x64

    mix assets.deploy --no-deps-check
  '';
}
