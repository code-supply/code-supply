{}:
{
  roleRef = {
    apiGroup = "rbac.authorization.k8s.io";
    kind = "ClusterRole";
    name = "hosting";
  };
  subjects = [
    {
      kind = "ServiceAccount";
      name = "hosting";
    }
  ];
}
