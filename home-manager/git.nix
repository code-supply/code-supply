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
      core.editor = "nvim";
      init = {
        defaultBranch = "main";
      };
      url = {
        "git@github.com:" = {
          pushInsteadOf = "https://github.com/";
        };
      };
    };
    signing = {
      key = null;
      signByDefault = true;
    };
  };
}
