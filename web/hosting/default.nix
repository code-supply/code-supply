{ lib
, coreutils
, elixir
, esbuild
, mixNixDeps
, mixRelease
, tailwindcss
, version
}:

let
  pname = "hosting";
  src = ./.;
  extractVersion = "${lib.getExe' elixir "elixir"} ${../../nix/extract_version.ex}";
in
mixRelease {
  inherit pname src version mixNixDeps;

  meta.mainProgram = pname;

  stripDebug = true;

  buildInputs = [ coreutils ];

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
    ln -sfv ${lib.getExe tailwindcss} _build/tailwind-linux-x64
    ln -sfv ${lib.getExe esbuild} _build/esbuild-linux-x64

    mix assets.deploy --no-deps-check
  '';
}
