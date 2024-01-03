{
  kubernetes.resources.certificates.hosting-www = {
    spec = {
      secretName = "hosting-www";
      issuerRef = {
        name = "letsencrypt-production-dns";
        kind = "ClusterIssuer";
      };
      commonName = "*.code.supply";
      dnsNames = [ "*.code.supply" ];
    };
  };
}
