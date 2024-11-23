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
        action = '':lua require("neotest").output_panel.toggle()<cr>'';
        key = "<F7>";
      }
      {
        action = '':lua require("neotest").output.open({ enter = true, auto_close = true })<cr>'';
        key = "<F8>";
      }
      {
        action = '':lua require("neotest").summary.toggle()<cr>'';
        key = "<F9>";
      }
      {
        action = '':w<cr>:lua require("neotest").run.run_last()<cr>'';
        key = "<F10>";
      }
      {
        action = '':w<cr>:lua require("neotest").run.run()<cr>'';
        key = "<F11>";
      }
      {
        action = '':w<cr>:lua require("neotest").run.run(vim.fn.expand("%"))<cr>'';
        key = "<F12>";
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
      }
      {
        action = ":nohlsearch<cr>";
        key = "<space>";
      }
      {
        action = "!i[sort<cr>";
        key = "<F5>";
      }
      {
        action = "<cmd>Telescope find_files<cr>";
        key = "<leader>ff";
      }
      {
        action = "<cmd>Telescope grep_string<cr>";
        key = "<leader>a";
      }
      {
        action = "<cmd>Telescope live_grep<cr>";
        key = "<leader>fg";
      }
      {
        action = "<cmd>Telescope buffers<cr>";
        key = "<leader>fb";
      }
      {
        action = "<cmd>Telescope help_tags<cr>";
        key = "<leader>fh";
      }
      {
        action = "<cmd>Telescope oldfiles<cr>";
        key = "<leader>fo";
      }
    ];
  };
}
