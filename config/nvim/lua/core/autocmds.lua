vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*.rs",
  callback = function()
    local cargo_toml = vim.fn.getcwd() .. "/Cargo.toml"
    if vim.fn.filereadable(cargo_toml) == 0 then
      local file = io.open(cargo_toml, "w")
      if file then
        file:write("[package]\nname = \"autogen\"\nversion = \"0.1.0\"\nedition = \"2021\"\n\n[dependencies]\n")
        file:close()
        print("Auto-generated minimal Cargo.toml")
      end
    end
  end,
})

