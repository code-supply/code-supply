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

    sessionVariables.SOPS_AGE_KEY_CMD = "age-plugin-yubikey -i";

    packages =
      with pkgs;
      let
        age-plugin-yubikey-57 = (
          rustPlatform.buildRustPackage rec {
            pname = "age-plugin-yubikey";
            version = "0.5.0-unstable-2024-11-02";

            src = fetchFromGitHub {
              owner = "str4d";
              repo = "age-plugin-yubikey";
              rev = "f8e16b7c6fad9d85855467d60ad635b21aaba115";
              hash = "sha256-wH9w6DbTdVrfrts7mdiYNkSa0xZKwhteHpHbgMnxqZo=";
            };

            cargoHash = "sha256-jomC3CpL1uXmWoqSZReeZH2VtEEquKvLesX/UFxI3h4=";

            nativeBuildInputs = [
              pkg-config
            ];

            buildInputs = [
              openssl
            ]
            ++ lib.optionals stdenv.hostPlatform.isLinux [ pcsclite ];

            meta = {
              description = "YubiKey plugin for age";
              mainProgram = "age-plugin-yubikey";
              homepage = "https://github.com/str4d/age-plugin-yubikey";
              changelog = "https://github.com/str4d/age-plugin-yubikey/blob/${src.rev}/CHANGELOG.md";
              license = with lib.licenses; [
                mit
                asl20
              ];
              maintainers = with lib.maintainers; [
                kranzes
                vtuan10
                adamcstephens
              ];
            };
          }
        );
      in
      [
        age
        age-plugin-yubikey-57
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
        proton-pass-cli
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
    enable = false;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };
}
