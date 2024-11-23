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
      telescope.enable = true;
      web-devicons.enable = true;
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
  };
}
