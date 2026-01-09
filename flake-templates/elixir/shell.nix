{ pkgs }:

with pkgs;

mkShell {
  packages = [
    elixir
    elixir-ls
    nixfmt
  ];

  shellHook = ''
    export ERL_AFLAGS="-kernel shell_history enabled shell_history_file_bytes 1024000"
  '';
}
