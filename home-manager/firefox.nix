{
  home.sessionVariables.BROWSER = "firefox";

  programs.firefox = {
    enable = true;
    profiles =
      {
        "Andrew" = {
          isDefault = true;
          id = 0;
          settings = {
            "apz.gtk.pangesture.delta_mode" = 2;
            "signon.rememberSignons" = false;
          };
          search.force = true;
        };
      };
  };
}
