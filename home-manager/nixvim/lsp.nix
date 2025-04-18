{
  programs.nixvim.plugins.lsp = {
    enable = true;

    servers = {
      bashls.enable = true;
      elixirls.enable = true;
      jsonls.enable = true;
      lua_ls.enable = true;
      terraformls.enable = true;
      nil_ls = {
        enable = true;
        settings = {
          formatting.command = [ "nixfmt" ];
        };
      };
      rust_analyzer = {
        installCargo = true;
        installRustc = true;
        enable = true;
      };
    };
  };
}
