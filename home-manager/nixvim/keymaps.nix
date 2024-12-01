{
  programs.nixvim = {
    globals = {
      mapleader = ",";
      maplocalleader = ",";
    };

    plugins.lsp.keymaps = {
      lspBuf = {
        "gD" = "declaration";
        "gd" = "definition";
        "gi" = "implementation";
        "gr" = "references";
        "K" = "hover";
        "<leader>k" = "signature_help";
        "<space>ca" = "code_action";
        "<space>rn" = "rename";
      };
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
        action.__raw = "vim.diagnostic.goto_prev";
        key = "[d";
        options.desc = "Previous diagnostic";
      }
      {
        action.__raw = "vim.diagnostic.goto_next";
        key = "]d";
        options.desc = "Next diagnostic";
      }
      {
        action = "!i[sort<cr>";
        key = "<F5>";
      }
      {
        action = '':w<cr>:TestSuite<cr>'';
        key = "<leader>ts";
        options.desc = "Test suite";
      }
      {
        action = '':w<cr>:TestLast<cr>'';
        key = "<leader>tr";
        options.desc = "Repeat last test run";
      }
      {
        action = '':w<cr>:TestNearest<cr>'';
        key = "<leader>tt";
        options.desc = "Test nearest";
      }
      {
        action = '':w<cr>:TestFile<cr>'';
        key = "<leader>tf";
        options.desc = "Test file";
      }
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
        options.desc = "Quit buffer";
      }
      {
        action = ":nohlsearch<cr>";
        key = "<space>";
      }
      {
        action = "<cmd>Telescope find_files<cr>";
        key = "<leader>ff";
        options.desc = "Find files";
      }
      {
        action = "<cmd>Telescope grep_string<cr>";
        key = "<leader>a";
        options.desc = "Grep string under cursor";
      }
      {
        action = "<cmd>Telescope live_grep<cr>";
        key = "<leader>fg";
        options.desc = "Find text or pattern";
      }
      {
        action = "<cmd>Telescope buffers<cr>";
        key = "<leader>fb";
        options.desc = "Find buffers";
      }
      {
        action = "<cmd>Telescope help_tags<cr>";
        key = "<leader>fh";
        options.desc = "Find in help";
      }
      {
        action = "<cmd>Telescope oldfiles<cr>";
        key = "<leader>fo";
        options.desc = "Find recent (old) files";
      }
    ];
  };
}
