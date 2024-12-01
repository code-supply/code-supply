{ pkgs, ... }:

{
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [
      {
        plugin = vim-test;
        config = ''
          let g:test#basic#start_normal = 1
        '';
      }
    ];
  };
}
