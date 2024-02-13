{ stdenv
, version
, ...
}:

stdenv.mkDerivation {
  inherit version;
  pname = "code-supply";

  src = ./.;

  buildPhase = ''
  '';

  installPhase = ''
    mkdir $out
    cp -r public/. $out/
  '';
}
