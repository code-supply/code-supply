{
  home = {
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    username = "andrew";
    homeDirectory = "/home/andrew";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "22.11";

    sessionVariables.FLAKE_CONFIG_URI = "/home/andrew/workspace/code-supply";
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
  };
}
