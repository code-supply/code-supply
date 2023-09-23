{ kubenix
, system
, lib
, hostingDockerImage
}:
(kubenix.evalModules.${system} (
  {
    module = { kubenix, ... }:
      let
        namespace = "hosting";
      in
      {
        imports = [ kubenix.modules.k8s ];
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

            clusterRoles.hosting = import ./k8s/clusterRole.nix { };
            clusterRoleBindings.hosting-can-manage-sites = import ./k8s/clusterRoleBinding.nix { inherit namespace; };
            certificates.hosting-www = import ./k8s/certificate.nix { };
            deployments.hosting = import ./k8s/deployment.nix {
              inherit lib;
              image = with hostingDockerImage; "${imageName}:${imageTag}";
            };
            services.hosting = import ./k8s/service.nix { };
            services.hosting-headless = import ./k8s/headless-service.nix { };
            serviceAccounts.hosting = { };
          };
        };
      };
  })).config.kubernetes.result
