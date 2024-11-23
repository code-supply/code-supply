{
  programs.nixvim.plugins = {
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
    luasnip.enable = true;
  };
}
