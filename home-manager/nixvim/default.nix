{ pkgs, ... }:

{
  imports = [
    ./keymaps.nix
    ./lsp.nix
    ./treesitter.nix
  ];

  programs.nixvim = {
    enable = true;

    plugins = {
      commentary.enable = true;
      fidget.enable = true;
      telescope.enable = true;
      web-devicons.enable = true;

      cmp = {
        enable = true;
        settings = {
          sources = [
            { name = "buffer"; }
            { name = "luasnip"; }
            { name = "nvim_lsp"; }
            { name = "path"; }
          ];
          snippet.expand = ''
            function(args)
              require('luasnip').lsp_expand(args.body)
            end
          '';
        };
      };
    };

    extraPlugins = with pkgs.vimPlugins; [
      elixir-tools-nvim
    ];

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
