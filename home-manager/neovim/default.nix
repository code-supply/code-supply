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
        elixir-tools-nvim
        fidget-nvim
        gruvbox
        idris2-vim
        luasnip
        null-ls-nvim
        nvim-cmp
        nvim-lspconfig
        nvim-treesitter.withAllGrammars
        plenary-nvim
        telescope-nvim
        vim-commentary
        vim-fugitive
        vim-gitgutter
        vim-gnupg
        vim-repeat
        vim-shellcheck
        vim-suda
        vim-surround
        vim-test
        vim-unimpaired
      ];
    };
  };
}
