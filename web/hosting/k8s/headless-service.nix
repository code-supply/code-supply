{
  kubernetes.resources.services.hosting-headless.spec = {
    type = "ClusterIP";
    clusterIP = "None";
    selector = {
      app = "hosting";
    };
    ports = [
      {
        name = "tcp-erlang";
        port = 5555;
        targetPort = "tcp-erlang";
      }
      {
        name = "tcp-epmd";
        port = 4369;
        targetPort = "tcp-epmd";
      }
    ];
  };
}
