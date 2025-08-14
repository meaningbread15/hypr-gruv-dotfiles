-- Format on save and linters
return {
	"nvimtools/none-ls.nvim",
	dependencies = {
		"nvimtools/none-ls-extras.nvim",
		"jayp0521/mason-null-ls.nvim", -- ensure dependencies are installed
	},
	config = function()
		local null_ls = require("null-ls")
		local formatting = null_ls.builtins.formatting -- to setup formatters
		local diagnostics = null_ls.builtins.diagnostics -- to setup linters
		local code_actions = null_ls.builtins.code_actions -- to setup code actions

		-- list of formatters & linters for mason to install
		require("mason-null-ls").setup({
			ensure_installed = {
				-- Existing
				"checkmake",
				"prettier", -- ts/js formatter
				"eslint_d", -- ts/js linter
				"shfmt",

				-- C/C++
				"clang-format",
				"cppcheck", -- Static analysis for C/C++

				-- Java
				"google-java-format",
				"checkstyle", -- Java linter

				-- Go
				"gofumpt", -- Go formatter (stricter than gofmt)
				"goimports", -- Go import formatter
				"golangci-lint", -- Go linter suite
				"golines", -- Go long line formatter

				-- JavaScript/TypeScript (additional)
				"prettierd", -- Faster prettier

				-- C#
				-- 'csharpier',   -- C# formatter

				-- General
				"codespell", -- Spell checker for code
				"gitlint", -- Git commit message linter
			},
			-- auto-install configured formatters & linters (with null-ls)
			automatic_installation = true,
		})

		-- Helper function to safely add sources
		local function safe_add(source_table, source)
			if source then
				table.insert(source_table, source)
			end
		end

		local sources = {}

		-- Existing sources
		safe_add(sources, diagnostics.checkmake)
		safe_add(sources, formatting.prettier and formatting.prettier.with({
			filetypes = { "html", "json", "yaml", "markdown", "css", "scss", "less" },
		}))
		safe_add(sources, formatting.stylua)
		safe_add(sources, formatting.shfmt and formatting.shfmt.with({ args = { "-i", "4" } }))
		safe_add(sources, formatting.terraform_fmt)

		-- Python (using none-ls-extras)
		local ruff_status, ruff_format = pcall(require, "none-ls.formatting.ruff")
		if ruff_status then
			safe_add(sources, ruff_format.with({ extra_args = { "--extend-select", "I" } }))
		end

		local ruff_format_status, ruff_fmt = pcall(require, "none-ls.formatting.ruff_format")
		if ruff_format_status then
			safe_add(sources, ruff_fmt)
		end

		-- C/C++
		safe_add(sources, formatting.clang_format and formatting.clang_format.with({
			filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
			extra_args = { "--style=Google" }, -- You can change to LLVM, Mozilla, WebKit, etc.
		}))
		safe_add(sources, diagnostics.cppcheck and diagnostics.cppcheck.with({
			args = {
				"--enable=warning,style,performance,portability",
				"--inline-suppr",
				"--suppress=missingIncludeSystem",
				"--suppress=unmatchedSuppression",
				"--quiet",
				"--template=gcc",
				"$FILENAME",
			},
		}))

		-- Java
		safe_add(sources, formatting.google_java_format)
		safe_add(sources, diagnostics.checkstyle and diagnostics.checkstyle.with({
			extra_args = { "-c", "/google_checks.xml" }, -- You can customize the config
		}))

		-- Go
		safe_add(sources, formatting.gofumpt)
		safe_add(sources, formatting.goimports)
		safe_add(sources, formatting.golines and formatting.golines.with({
			extra_args = { "--max-len=100" }, -- Adjust line length as needed
		}))
		safe_add(sources, diagnostics.golangci_lint and diagnostics.golangci_lint.with({
			extra_args = { "--fast" },
		}))

		-- JavaScript/TypeScript (enhanced)
		safe_add(sources, formatting.prettierd and formatting.prettierd.with({
			filetypes = {
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
				"vue",
				"css",
				"scss",
				"less",
				"html",
				"json",
				"jsonc",
				"yaml",
				"markdown",
			},
		}))

		-- Use eslint_d from none-ls-extras
		local eslint_status, eslint_d = pcall(require, "none-ls.diagnostics.eslint_d")
		if eslint_status then
			safe_add(
				sources,
				eslint_d.with({
					condition = function(utils)
						return utils.root_has_file({
							".eslintrc.js",
							".eslintrc.cjs",
							".eslintrc.yaml",
							".eslintrc.yml",
							".eslintrc.json",
							"eslint.config.js",
						})
					end,
				})
			)
		end

		-- C#
		--safe_add(sources, formatting.csharpier)

		-- General purpose
		safe_add(sources, diagnostics.codespell and diagnostics.codespell.with({
			filetypes = { "text", "markdown", "gitcommit" },
		}))
		safe_add(sources, diagnostics.gitlint)

		-- Code actions
		local eslint_code_action_status, eslint_code_actions = pcall(require, "none-ls.code_actions.eslint_d")
		if eslint_code_action_status then
			safe_add(sources, eslint_code_actions)
		end
		safe_add(sources, code_actions.gitsigns)

		local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

		null_ls.setup({
			-- debug = true, -- Enable debug mode. Inspect logs with :NullLsLog.
			sources = sources,
			-- you can reuse a shared lspconfig on_attach callback here
			on_attach = function(client, bufnr)
				if client.supports_method("textDocument/formatting") then
					vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = augroup,
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.format({
								async = false,
								-- Filter to only use null-ls for formatting (avoid conflicts with LSPs)
								filter = function(client)
									return client.name == "null-ls"
								end,
							})
						end,
					})
				end
			end,
		})
	end,
}
