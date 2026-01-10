{ pkgs, ... }:
let
  pkcs11Library = "${pkgs.yubico-piv-tool}/lib/libykcs11.so";
in
{
  home = {
    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/workspace/google-cloud-sdk/bin"
    ];

    shellAliases = {
      "s" = "kitten ssh";
      "ssh-add" = "ssh-add -s ${pkcs11Library}";
    };

    packages = with pkgs; [
      binutils
      cntr
      dig
      dive
      dust
      file
      ghostty
      gnupg
      htop
      iftop
      jq
      lsof
      moreutils
      nix-index
      nix-tree
      nmap
      opensc
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
      extraOptionOverrides = {
        PKCS11Provider = pkcs11Library;
      };
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        klix = {
          hostname = "46.62.161.130";
          user = "root";
        };
        unhinged = {
          hostname = "192.168.1.182";
          port = 2222;
        };
        x200 = {
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
