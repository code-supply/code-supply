{ namespace }:
{
  roleRef = {
    apiGroup = "rbac.authorization.k8s.io";
    kind = "ClusterRole";
    name = "hosting";
  };
  subjects = [
    {
      inherit namespace;
      kind = "ServiceAccount";
      name = "hosting";
    }
  ];
}
