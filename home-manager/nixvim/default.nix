{ pkgs, ... }:

{
  programs.nixvim = {
    enable = true;

    plugins = {
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
