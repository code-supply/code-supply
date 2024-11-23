{ pkgs, ... }:

{
  programs.nixvim = {
    enable = true;

    plugins = {
      commentary.enable = true;

      cmp = {
        enable = true;
        settings = {
          mapping = {
            "<C-b>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.abort()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
          };

          sources = [
            { name = "nvim_lsp"; }
            { name = "path"; }
            { name = "buffer"; }
          ];
        };
      };

      fidget.enable = true;

      lsp = {
        enable = true;

        servers = {
          bashls.enable = true;
          jsonls.enable = true;
          lua_ls.enable = true;
          tailwindcss.enable = true;
          terraformls.enable = true;
          nixd = {
            enable = true;
            settings = {
              formatting.command = [ "nixfmt" ];
            };
          };
          rust_analyzer = {
            installCargo = true;
            installRustc = true;
            enable = true;
          };
        };
      };

      treesitter = {
        enable = true;
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          awk
          bash
          c
          cmake
          comment
          cpp
          css
          csv
          diff
          dot
          eex
          elixir
          erlang
          fish
          git-config
          gitignore
          git-rebase
          gleam
          go
          gomod
          gpg
          haskell
          hcl
          heex
          helm
          html
          http
          java
          javascript
          jq
          json
          kotlin
          lua
          make
          markdown
          markdown-inline
          mermaid
          nix
          passwd
          properties
          readline
          regex
          rust
          sql
          ssh-config
          terraform
          toml
          typescript
          vim
          vimdoc
          xml
          yaml
        ];
      };
    };

    extraPlugins = with pkgs.vimPlugins; [
      elixir-tools-nvim
    ];

    globals = {
      mapleader = ",";
      maplocalleader = ",";
    };

    opts = {
      number = true;
      tabstop = 2;
      shiftwidth = 2;
      softtabstop = 2;
      expandtab = true;
      wrap = false;
    };

    autoCmd = [
      {
        event = [ "BufWritePre" ];
        callback = {
          __raw = "function() vim.lsp.buf.format({ async = false }) end";
        };
      }
    ];
  };
}
