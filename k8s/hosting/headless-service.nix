{}:
{
  spec = {
    type = "ClusterIP";
    clusterIP = "None";
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
