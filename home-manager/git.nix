{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Andrew Bruce";
        email = "me@andrewbruce.net";
      };

      alias = {
        br = "branch";
        ci = "commit --verbose";
        co = "checkout";
        di = "diff";
        st = "status";
      };

      core.editor = "nvim";

      core.pager = "${pkgs.delta}/bin/delta";
      delta = {
        hyperlinks = true;
        navigate = true;
        side-by-side = true;
      };

      diff.colorMoved = "default";
      interactive.diffFilter = "${pkgs.delta}/bin/delta --color-only";
      merge.conflictstyle = "diff3";

      pull.rebase = true;
      rebase.autosquash = true;
      rebase.autostash = true;

      init = {
        defaultBranch = "main";
      };
      url = {
        "git@github.com:" = {
          pushInsteadOf = "https://github.com/";
        };
      };

      gpg = {
        format = "ssh";
        ssh.defaultKeyCommand = "ssh-add -L";
        ssh.allowedSignersFile =
          let
            path = pkgs.writeTextFile {
              name = "allowed-signers";
              text = ''
                me@andrewbruce.net namespaces="git" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOfher5cvUlwuLyrhTjbQSj8UWT7LTQ/eXd3rSXrJOFU
              '';
            };
          in
          "${path}";
      };
    };

    signing = {
      key = null;
      signByDefault = true;
    };
  };
}
