return {
  'sainnhe/gruvbox-material',
  lazy = false,
  priority = 1000,
  config = function()

    vim.g.gruvbox_material_transparent_background = 1
    vim.g.gruvbox_material_enable_italic = true
    vim.g.gruvbox_material_background = "medium"
    vim.cmd.colorscheme('gruvbox-material')

    local transparent = true
    vim.keymap.set('n', '<leader>bg', function()
      transparent = not transparent
      vim.g.gruvbox_material_transparent_background = transparent and 1 or 0
      vim.cmd.colorscheme('gruvbox-material')
    end, { noremap = true, silent = true })
  end
}

