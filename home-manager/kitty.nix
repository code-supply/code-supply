{ pkgs, ... }: {
  fonts.fontconfig.enable = true;

  programs.kitty = {
    enable = true;
    font = {
      package = pkgs.fira-code;
      name = "Fira Code";
      size = 14;
    };
    settings = {
      enabled_layouts = "stack,splits";
      adjust_line_height = "120%";
      listen_on = "unix:/tmp/mykitty";
      allow_remote_control = "yes";
      hide_window_decorations = "yes";
    };
    keybindings = {
      "ctrl+shift+enter" = "launch --cwd=current";
      "ctrl+shift+t" = "launch --cwd=current --type tab";
      "ctrl+shift+f4" = "launch --location=split";
      "ctrl+shift+f5" = "launch --location=hsplit";
      "ctrl+shift+f6" = "launch --location=vsplit";
      "ctrl+shift+f7" = "layout_action rotate";
    };
  };

  home.sessionVariables.KITTY_LISTEN_ON = "unix:/tmp/mykitty-$PPID";
}
