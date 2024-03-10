{
  services.plausible = {
    enable = true;

    adminUser = {
      email = "me@andrewbruce.net";
      passwordFile = "/plausible/pass";
    };

    server = {
      baseUrl = "https://plausible.code.supply";
      secretKeybaseFile = "/plausible/secret";
    };
  };
}
