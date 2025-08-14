return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
    config = function()
            vim.keymap.set('n', '<C-n>', '<Cmd>Neotree toggle<CR>', { noremap = true, silent = true })
            vim.keymap.set('n', '<C-e>', '<Cmd>Neotree toggle<CR>', { noremap = true, silent = true })
            vim.keymap.set('n', '\\', '<Cmd>Neotree toggle<CR>', { noremap = true, silent = true })
        require("neo-tree").setup({
            window = {
                width = 25,
            },
        })
    end,
}

