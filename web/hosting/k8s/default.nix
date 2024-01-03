{ kubenix
, system
, lib
, hostingDockerImage
}:
(kubenix.evalModules.${system} (
  {
    module = { kubenix, config, ... }:
      let
        namespace = "hosting";
      in
      {
        imports = [
          kubenix.modules.k8s
          kubenix.modules.docker
          ./clusterRole.nix
          ./clusterRoleBinding.nix
          ./certificate.nix
          ./deployment.nix
          ./service.nix
          ./headless-service.nix
        ];

        docker = {
          images.hosting = {
            name = hostingDockerImage.imageName;
            tag = hostingDockerImage.imageTag;
          };
        };

        kubernetes = {
          inherit namespace;

          customTypes = [{
            group = "cert-manager.io";
            version = "v1";
            kind = "Certificate";
            attrName = "certificates";
            module = { };
          }];

          resources = {
            namespaces.${namespace} = { };
            serviceAccounts.hosting = { };
          };
        };
      };
  })).config.kubernetes.result
