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

            clusterRoles.hosting = import ./clusterRole.nix { };
            clusterRoleBindings.hosting-can-manage-sites = import ./clusterRoleBinding.nix { inherit namespace; };
            certificates.hosting-www = import ./certificate.nix { };
            deployments.hosting = import ./deployment.nix {
              inherit lib;
              image = with hostingDockerImage; "${imageName}:${imageTag}";
            };
            services.hosting = import ./service.nix { };
            services.hosting-headless = import ./headless-service.nix { };
            serviceAccounts.hosting = { };
          };
        };
      };
  })).config.kubernetes.result
