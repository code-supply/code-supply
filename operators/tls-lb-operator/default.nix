{ mixNixDeps
, mixRelease
, version
}:

mixRelease {
  inherit mixNixDeps version;

  pname = "tls-lb-operator";
  src = ./.;
}
