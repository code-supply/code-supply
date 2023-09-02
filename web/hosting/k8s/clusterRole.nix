{}:
{
  rules = [
    {
      apiGroups = [ "cert-manager.io" ];
      resources = [ "certificates" ];
      verbs = [ "create" "delete" ];
    }
    {
      apiGroups = [ "" ];
      resources = [ "endpoints" ];
      verbs = [ "list" ];
    }
  ];
}
