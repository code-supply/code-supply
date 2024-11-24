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

    colorschemes.gruvbox.enable = true;

    plugins = {
      commentary.enable = true;
      fidget.enable = true;
      fugitive.enable = true;
      gitgutter.enable = true;
      neotest = {
        enable = true;
        adapters = {
          elixir.enable = true;
        };
      };
      nvim-surround.enable = true;
      telescope.enable = true;
      web-devicons.enable = true;
      which-key.enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; [
      vim-gnupg
      vim-repeat
      vim-unimpaired
    ];

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
