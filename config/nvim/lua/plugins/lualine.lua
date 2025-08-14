-- Set lualine as statusline
return {
  'nvim-lualine/lualine.nvim',
  config = function()
    -- Gruvbox Material Soft color palette
    local colors = {
      bg = '#32302f',
      fg = '#d4be98',
      red = '#ea6962',
      green = '#a9b665',
      yellow = '#d8a657',
      blue = '#7daea3',
      purple = '#d3869b',
      cyan = '#89b482',
      orange = '#e78a4e',
      gray = '#928374',
      bg0 = '#32302f',
      bg1 = '#3c3836',
      bg2 = '#504945',
      bg3 = '#665c54',
      bg4 = '#7c6f64',
      fg0 = '#d4be98',
      fg1 = '#ddc7a1',
      fg2 = '#c6b696',
      fg3 = '#b2a191',
      fg4 = '#a69d94',
    }

    -- Gruvbox Material Soft theme for lualine with custom accent colors
    local gruvbox_theme = {
      normal = {
        a = { fg = colors.bg0, bg = '#f1e4ba', gui = 'bold' },
        b = { fg = colors.fg1, bg = colors.bg2 },
        c = { fg = colors.fg0, bg = colors.bg1 },
      },
      insert = {
        a = { fg = colors.bg0, bg = '#766e55', gui = 'bold' },
        b = { fg = colors.fg1, bg = colors.bg2 },
        c = { fg = colors.fg0, bg = colors.bg1 },
      },
      visual = {
        a = { fg = colors.bg0, bg = '#f1e4ba', gui = 'bold' },
        b = { fg = colors.fg1, bg = colors.bg2 },
        c = { fg = colors.fg0, bg = colors.bg1 },
      },
      replace = {
        a = { fg = '#f1e4ba', bg = '#d94a30', gui = 'bold' },
        b = { fg = colors.fg1, bg = colors.bg2 },
        c = { fg = colors.fg0, bg = colors.bg1 },
      },
      command = {
        a = { fg = colors.bg0, bg = '#766e55', gui = 'bold' },
        b = { fg = colors.fg1, bg = colors.bg2 },
        c = { fg = colors.fg0, bg = colors.bg1 },
      },
      inactive = {
        a = { fg = colors.fg4, bg = colors.bg1, gui = 'bold' },
        b = { fg = colors.fg4, bg = colors.bg1 },
        c = { fg = colors.fg4, bg = colors.bg1 },
      },
    }

    -- Import color theme based on environment variable NVIM_THEME
    local env_var_nvim_theme = os.getenv 'NVIM_THEME' or 'gruvbox_material_soft'
    
    -- Define a table of themes
    local themes = {
      gruvbox_material_soft = gruvbox_theme,
      gruvbox = gruvbox_theme, -- fallback alias
    }

    local mode = {
      'mode',
      fmt = function(str)
        -- return ' ' .. str:sub(1, 1) -- displays only the first character of the mode
        return ' ' .. str
      end,
    }

    local filename = {
      'filename',
      file_status = true, -- displays file status (readonly status, modified status)
      path = 0,           -- 0 = just filename, 1 = relative path, 2 = absolute path
    }

    local hide_in_width = function()
      return vim.fn.winwidth(0) > 100
    end

    local diagnostics = {
      'diagnostics',
      sources = { 'nvim_diagnostic' },
      sections = { 'error', 'warn' },
      symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
      colored = true,
      diagnostics_color = {
        error = { fg = colors.red },
        warn = { fg = colors.yellow },
        info = { fg = colors.blue },
        hint = { fg = colors.cyan },
      },
      update_in_insert = false,
      always_visible = false,
      cond = hide_in_width,
    }

    local diff = {
      'diff',
      colored = true,
      diff_color = {
        added = { fg = colors.green },
        modified = { fg = colors.yellow },
        removed = { fg = colors.red },
      },
      symbols = { added = ' ', modified = ' ', removed = ' ' }, -- changes diff symbols
      cond = hide_in_width,
    }

    require('lualine').setup {
      options = {
        icons_enabled = true,
        theme = themes[env_var_nvim_theme],
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
        disabled_filetypes = { 'alpha', 'neo-tree', 'Avante' },
        always_divide_middle = true,
        globalstatus = true,
      },
      sections = {
        lualine_a = { mode },
        lualine_b = { 'branch' },
        lualine_c = { filename },
        lualine_x = { diagnostics, diff, { 'encoding', cond = hide_in_width }, { 'filetype', cond = hide_in_width } },
        lualine_y = { 'location' },
        lualine_z = { 'progress' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { { 'location', padding = 0 } },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      extensions = { 'fugitive' },
    }
  end,
}
