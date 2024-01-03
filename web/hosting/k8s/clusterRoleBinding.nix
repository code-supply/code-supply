{ config, ... }:
{
  kubernetes.resources.clusterRoleBindings.hosting-can-manage-sites = {
    roleRef = {
      apiGroup = "rbac.authorization.k8s.io";
      kind = "ClusterRole";
      name = "hosting";
    };
    subjects = [
      {
        inherit (config.kubernetes) namespace;
        kind = "ServiceAccount";
        name = "hosting";
      }
    ];
  };
}
