{
  lib,
  image,
}: let
  name = "hosting";
  mapAttrsToNameValue =
    lib.attrsets.mapAttrsToList
    (name: value: {inherit name value;});
in {
  metadata.labels.app = name;

  spec = {
    replicas = 3;

    selector.matchLabels.app = name;

    template = {
      metadata.labels.app = name;

      spec = {
        serviceAccountName = name;

        containers.hosting = let
          tcpPort = name: containerPort: {
            inherit name containerPort;
            protocol = "TCP";
          };
          httpPort = tcpPort "http" 4000;
        in {
          inherit image;

          envFrom = [
            {secretRef = {inherit name;};}
          ];

          readinessProbe = {
            failureThreshold = 3;
            httpGet = {
              httpHeaders = [
                {
                  name = "Host";
                  value = "${name}.code.supply";
                }
              ];
              path = "/";
              port = httpPort.name;
              scheme = "HTTP";
            };
            periodSeconds = 10;
            successThreshold = 1;
            timeoutSeconds = 1;
          };

          resources = {
            limits = {
              cpu = "1";
              memory = "250Mi";
            };
            requests = {
              cpu = "100m";
              memory = "55Mi";
            };
          };

          ports = [
            httpPort
            (tcpPort "tcp-erlang" 5555)
            (tcpPort "tcp-epmd" 4369)
          ];

          env =
            (mapAttrsToNameValue
              {
                BUCKET_NAME = "hosting-uploads";
                ELIXIR_ERL_OPTIONS = "-kernel inet_dist_listen_min 5555 inet_dist_listen_max 5556";
                RELEASE_DISTRIBUTION = "name";
                RELEASE_NODE = "${name}@$(POD_IP)";
              })
            ++ [
              {
                name = "POD_IP";
                valueFrom.fieldRef.fieldPath = "status.podIP";
              }
            ];
        };
      };
    };
  };
}
