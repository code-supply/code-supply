{
  programs.git = {
    enable = true;
    userName = "Andrew Bruce";
    userEmail = "me@andrewbruce.net";
    aliases = {
      br = "branch";
      ci = "commit --verbose";
      co = "checkout";
      di = "diff";
      st = "status";
    };
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      url = {
        "git@github.com:" = {
          pushInsteadOf = "https://github.com/";
        };
      };
    };
  };
}
