{ pkgs, lib, ... }: {
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      extraLuaConfig =
        let
          luaConfigs = lib.sources.sourceFilesBySuffices ./. [ ".lua" ];
        in
        ''
          package.path = '${luaConfigs}/?.lua'
          require 'init'
        '';
      plugins = with pkgs.vimPlugins; [
        cmp-nvim-lsp
        comment-nvim
        elixir-tools-nvim
        fidget-nvim
        gruvbox
        luasnip
        idris2-vim
        null-ls-nvim
        nvim-cmp
        nvim-lspconfig
        nvim-treesitter.withAllGrammars
        plenary-nvim
        suda-vim
        telescope-nvim
        vim-fugitive
        vim-gitgutter
        vim-gnupg
        vim-repeat
        vim-shellcheck
        vim-surround
        vim-test
        vim-unimpaired
      ];
    };
  };
}
