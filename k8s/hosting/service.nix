{}:
{
  spec = {
    type = "ClusterIP";
    selector = {
      app = "hosting";
    };
    ports = [
      {
        port = 80;
        name = "http";
        targetPort = "http";
      }
    ];
    ipFamilies = [ "IPv4" "IPv6" ];
    ipFamilyPolicy = "PreferDualStack";
  };
}
