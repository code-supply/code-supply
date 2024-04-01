{ pkgs, ... }: {
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      extraLuaConfig = builtins.readFile neovim/init.lua;
      plugins = with pkgs.vimPlugins; [
        cmp-nvim-lsp
        comment-nvim
        elixir-tools-nvim
        gruvbox
        luasnip
        idris2-vim
        null-ls-nvim
        nvim-cmp
        nvim-lspconfig
        nvim-lsp-ts-utils
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
