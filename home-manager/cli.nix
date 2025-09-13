{ pkgs, ... }:
{
  home = {
    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/workspace/google-cloud-sdk/bin"
    ];

    shellAliases = {
      "ssh" = "kitten ssh";
    };

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
      pv
      ripgrep
      sops
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
        "x200" = {
          hostname = "192.168.1.124";
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
    pinentry.package = pkgs.pinentry-gnome3;
  };
}
