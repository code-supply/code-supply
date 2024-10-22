vim.g["test#custom_transformations"] = {
  direnv = function(cmd)
    return 'direnv exec "$(git rev-parse --show-toplevel)" ' .. cmd
  end
}
vim.g["test#transformation"] = "direnv"
