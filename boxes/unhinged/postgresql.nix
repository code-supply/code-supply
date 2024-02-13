{
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    ensureDatabases = [
      "affable"
      "atc"
      "concourse"
      "hosting"
    ];
    ensureUsers = [
      {
        name = "affable";
        ensureDBOwnership = true;
      }
      {
        name = "hosting";
        ensureDBOwnership = true;
      }
      {
        name = "concourse";
        ensureDBOwnership = true;
      }
    ];
    authentication = ''
      # type  database  user      address           method
      local   all       all                         trust
      host    all       all       127.0.0.1/32      trust
      host    all       all       ::1/128           trust
      host    affable   affable   192.168.1.0/24    trust
      host    affable   affable   10.42.0.0/16      trust
      host    hosting   hosting   192.168.1.0/24    trust
      host    hosting   hosting   10.42.0.0/16      trust
      host    atc       concourse 192.168.1.0/24    trust
      host    atc       concourse 10.42.0.0/16      trust
    '';
  };
}
