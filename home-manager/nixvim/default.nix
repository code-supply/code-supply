{ pkgs, ... }:

{
  imports = [
    ./completion.nix
    ./format-on-save.nix
    ./keymaps.nix
    ./lsp.nix
    ./treesitter.nix
  ];

  programs.nixvim = {
    enable = true;

    plugins = {
      commentary.enable = true;
      fidget.enable = true;
      fugitive.enable = true;
      gitgutter.enable = true;
      nvim-surround.enable = true;
      telescope.enable = true;
      web-devicons.enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; [
      elixir-tools-nvim
      vim-gnupg
      vim-repeat
      vim-unimpaired
    ];
    extraConfigLua = ''
      require('elixir').setup({
        elixirls = { cmd = { "elixir-ls" } }
      })
    '';

    opts =
      let
        spaces = 2;
      in
      {
        expandtab = true;
        number = true;
        shiftwidth = spaces;
        softtabstop = spaces;
        tabstop = spaces;
        wrap = false;
      };
  };
}
