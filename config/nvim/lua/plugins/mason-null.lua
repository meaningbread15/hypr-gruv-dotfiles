return {
  "jay-babu/mason-null-ls.nvim",
  dependencies = {
    "williamboman/mason.nvim",
    "nvimtools/none-ls.nvim",
    "williamboman/mason-core.nvim", -- <-- add this line
  },
  config = function()
    require("mason-null-ls").setup()
  end
}

