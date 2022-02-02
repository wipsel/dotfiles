local ok, treesitter = pcall(require, "nvim-treesitter.configs")
if not ok then
  print("Error could not start treesitter")
  return
end

treesitter.setup {
  ensure_installed = "maintained",
  highlight = {
    enable = true,
  },
  indent = {
    enable = false,
  }
}
