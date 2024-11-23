{
  programs.nixvim = {
    globals = {
      mapleader = ",";
      maplocalleader = ",";
    };

    plugins.cmp.settings.mapping = {
      "<C-b>" = "cmp.mapping.scroll_docs(-4)";
      "<C-f>" = "cmp.mapping.scroll_docs(4)";
      "<C-Space>" = "cmp.mapping.complete()";
      "<C-e>" = "cmp.mapping.abort()";
      "<CR>" = "cmp.mapping.confirm({ select = true })";
    };

    keymaps = [
      {
        action = "<c-w>h";
        key = "<c-h>";
      }
      {
        action = "<c-w>j";
        key = "<c-j>";
      }
      {
        action = "<c-w>k";
        key = "<c-k>";
      }
      {
        action = "<c-w>l";
        key = "<c-l>";
      }
      {
        action = ":q<cr>";
        key = "<leader>q";
      }
      {
        action = ":nohlsearch<cr>";
        key = "<space>";
      }
      {
        action = "!i[sort<cr>";
        key = "<F5>";
      }
    ];
  };
}
