{ mixNixDeps
, mixRelease
, version
}:

mixRelease {
  inherit mixNixDeps version;

  pname = "tls-lb-operator";
  src = ./.;

  stripDebug = true;

  postInstall = ''
    mkdir $out/hooks
    echo '#!/bin/sh' > $out/hooks/tls_lb_operator
    echo '$out/bin/tls_lb_operator eval "TlsLbOperator.main(~w[$*])"' >> $out/hooks/tls_lb_operator
    chmod +x $out/hooks/tls_lb_operator
  '';
}
