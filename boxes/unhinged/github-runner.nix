{
  services.github-runner = {
    enable = true;
    tokenFile = "/run/secrets/github-runner/nixos.token";
    url = "https://github.com/code-supply/testnixrunner";
    extraLabels = [ "nixos" ];
  };
}
