{ pkgs, ... }:

{
  programs.nixvim.plugins.treesitter = {
    enable = true;
    grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
      awk
      bash
      c
      cmake
      comment
      cpp
      css
      csv
      diff
      dot
      eex
      elixir
      erlang
      fish
      git-config
      gitignore
      git-rebase
      gleam
      go
      gomod
      gpg
      haskell
      hcl
      heex
      helm
      html
      http
      java
      javascript
      jq
      json
      kotlin
      lua
      make
      markdown
      markdown-inline
      mermaid
      nix
      passwd
      properties
      readline
      regex
      rust
      sql
      ssh-config
      terraform
      toml
      typescript
      vim
      vimdoc
      xml
      yaml
    ];
  };

}
