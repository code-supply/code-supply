{ pkgs, ... }:
{
  home = {
    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/workspace/google-cloud-sdk/bin"
    ];

    packages = with pkgs; [
      binutils
      cntr
      dig
      dive
      du-dust
      file
      gnupg
      htop
      iftop
      jq
      lsof
      moreutils
      nix-index
      nix-tree
      nmap
      pass
      pciutils
      ripgrep
      sysfsutils
      unzip
      usbutils
      wget
      whois
      yubikey-manager
      zip
    ];
  };

  programs = {
    ssh = {
      enable = true;
      matchBlocks = {
        "unhinged" = {
          hostname = "192.168.1.182";
          port = 2222;
        };
      };
    };

    bottom.enable = true;

    bash = {
      enable = true;
      bashrcExtra = ''
        export PS1="\[\033[1;32m\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\$\[\033[0m\] "
        if command -v fly > /dev/null
        then
          source <(fly completion --shell=bash)
        fi
        bind 'Space: magic-space'
      '';
    };

    bat = {
      enable = true;
      config = {
        theme = "gruvbox-dark";
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    readline = {
      enable = true;
      bindings = {
        "\\e[A" = "history-search-backward";
        "\\e[B" = "history-search-forward";
      };
      variables = {
        completion-ignore-case = true;
      };
    };

    tmate.enable = true;
    tmux.enable = true;
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };
}
