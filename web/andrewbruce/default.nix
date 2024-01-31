{ stdenv
, version
, zola
, ...
}:

stdenv.mkDerivation {
  inherit version;
  pname = "andrewbruce";

  src = ./.;

  buildPhase = ''
    ${zola}/bin/zola build
  '';

  installPhase = ''
    mkdir $out
    cp -r public/. $out/
  '';
}
