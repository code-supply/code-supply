{
  programs.nixvim.plugins.lsp = {
    enable = true;

    servers = {
      bashls.enable = true;
      jsonls.enable = true;
      lua_ls.enable = true;
      tailwindcss.enable = true;
      terraformls.enable = true;
      nixd = {
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
