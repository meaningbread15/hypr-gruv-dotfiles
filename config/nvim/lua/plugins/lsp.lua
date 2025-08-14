-- File: lua/plugins/lsp.lua

return {
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Automatically install LSPs and related tools to stdpath for Neovim
    { 'mason-org/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
    'mason-org/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',

    -- Useful status updates for LSP.
    {
      'j-hui/fidget.nvim',
      opts = {
        notification = {
          window = {
            winblend = 0, -- Background color opacity in the notification window
          },
        },
      },
    },

    -- Allows extra capabilities provided by nvim-cmp
    'hrsh7th/cmp-nvim-lsp',
  },
  config = function()
    -- Configure diagnostic display
    vim.diagnostic.config({
      virtual_text = {
        enabled = true,
        source = "if_many",
        spacing = 2,
        prefix = '●',
      },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = '✘',
          [vim.diagnostic.severity.WARN] = '▲',
          [vim.diagnostic.severity.HINT] = '⚑',
          [vim.diagnostic.severity.INFO] = '»',
        },
      },
      underline = true,
      update_in_insert = true,
      severity_sort = true,
      float = {
        focusable = false,
        style = 'minimal',
        border = 'rounded',
        -- source = 'always',
        header = '',
        prefix = '',
      },
    })

    -- This autocommand sets up keymaps and other behavior when a language server is attached
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        -- Jump to the definition of the word under your cursor.
        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
        map('K', vim.lsp.buf.hover, 'Hover Documentation')
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        map('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
        map('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
        map('<leader>wl', function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, '[W]orkspace [L]ist Folders')

        -- Document highlighting
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        -- Inlay hints toggle
        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    -- LSP capabilities with nvim-cmp integration
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local has_cmp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
    if has_cmp then
      capabilities = vim.tbl_deep_extend('force', capabilities, cmp_nvim_lsp.default_capabilities())
    end

    -- Language server configurations
    -- This table is used to pass custom settings to mason-lspconfig
    local servers = {
      -- Lua
      lua_ls = {
        settings = {
          Lua = {
            completion = { callSnippet = 'Replace' },
            runtime = { version = 'LuaJIT' },
            workspace = {
              checkThirdParty = false,
              library = vim.api.nvim_get_runtime_file('', true),
            },
            diagnostics = {
              globals = { 'vim' },
              disable = { 'missing-fields' },
            },
            format = { enable = false },
          },
        },
      },
      
      -- Python
      pylsp = {
        settings = {
          pylsp = {
            plugins = {
              pyflakes = { enabled = false },
              pycodestyle = { enabled = false },
              autopep8 = { enabled = false },
              yapf = { enabled = false },
              mccabe = { enabled = false },
              pylsp_mypy = { enabled = false },
              pylsp_black = { enabled = false },
              pylsp_isort = { enabled = false },
            },
          },
        },
      },
      ruff = {}, -- Python linter/formatter

      -- Rust
      rust_analyzer = {
        -- NOTE: rust_analyzer requires a Cargo.toml file in the root of your project
        settings = {
          ['rust-analyzer'] = {
            cargo = { allFeatures = true, loadOutDirsFromCheck = true, buildScripts = { enable = true } },
            check = { command = "clippy" }, -- Enable clippy for better error checking
            procMacro = { enable = true, ignored = { ['async-trait'] = { 'async_trait' }, ['napi-derive'] = { 'napi' }, ['async-recursion'] = { 'async_recursion' } } },
            inlayHints = {
              bindingModeHints = { enable = false },
              chainingHints = { enable = true },
              closingBraceHints = { enable = true, minLines = 25 },
              closureReturnTypeHints = { enable = 'never' },
              lifetimeElisionHints = { enable = 'never', useParameterNames = false },
              maxLength = 25,
              parameterHints = { enable = true },
              reborrowHints = { enable = 'never' },
              renderColons = true,
              typeHints = { enable = true, hideClosureInitialization = false, hideNamedConstructor = false },
            },
          },
        },
      },

      -- C/C++
      clangd = {
        -- NOTE: clangd works best with a compile_commands.json or compile_flags.txt file in your project root
        cmd = {
          'clangd',
          '--background-index',
          '--clang-tidy',
          '--header-insertion=iwyu',
          '--completion-style=detailed',
          '--function-arg-placeholders',
          '--fallback-style=llvm',
        },
        filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
        single_file_support = true,
        root_dir = function(fname)
          -- This is a very common way to detect the project root for C/C++
          return require('lspconfig.util').root_pattern(
            'compile_commands.json',
            'compile_flags.txt',
            '.git'
          )(fname) or require('lspconfig.util').find_git_ancestor(fname)
        end,
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
        settings = {
          clangd = {
            InlayHints = { Designators = true, Enabled = true, ParameterNames = true, DeducedTypes = true },
            fallbackFlags = { '-std=c++17' },
          },
        },
      },

      -- Java - Enhanced configuration
      jdtls = {
        -- NOTE: jdtls requires a Maven (pom.xml) or Gradle (build.gradle) project structure
        cmd = { 'jdtls' },
        filetypes = { 'java' },
        single_file_support = false, -- JDTLS doesn't support single files well
        root_dir = require('lspconfig.util').root_pattern(
          'pom.xml',
          'build.gradle',
          'build.gradle.kts',
          '.git'
        ),
        settings = {
          java = {
            eclipse = { downloadSources = true },
            configuration = { updateBuildConfiguration = 'interactive' },
            maven = { downloadSources = true },
            implementationsCodeLens = { enabled = true },
            referencesCodeLens = { enabled = true },
            references = { includeDecompiledSources = true },
            format = { enabled = true },
            compile = { nullAnalysis = { mode = 'automatic' } },
            codeGeneration = {
              toString = { template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}' },
              hashCodeEquals = { useJava7Objects = true },
              useBlocks = true,
            },
          },
          signatureHelp = { enabled = true },
          completion = {
            favoriteStaticMembers = {
              'org.hamcrest.MatcherAssert.assertThat',
              'org.hamcrest.Matchers.*',
              'org.hamcrest.CoreMatchers.*',
              'org.junit.jupiter.api.Assertions.*',
              'java.util.Objects.requireNonNull',
              'java.util.Objects.requireNonNullElse',
              'org.mockito.Mockito.*',
            },
          },
          contentProvider = { preferred = 'fernflower' },
          extendedClientCapabilities = {
            progressReportsSupported = true,
            classFileContentsSupported = true,
            generateToStringPromptSupported = true,
            hashCodeEqualsPromptSupported = true,
            advancedExtractRefactoringSupported = true,
            advancedOrganizeImportsSupported = true,
            generateConstructorsPromptSupported = true,
            generateDelegateMethodsPromptSupported = true,
            moveRefactoringSupported = true,
          },
          sources = {
            organizeImports = {
              starThreshold = 9999,
              staticStarThreshold = 9999,
            },
          },
        },
      },

      -- Go
      gopls = {
        settings = {
          gopls = {
            experimentalPostfixCompletions = true,
            analyses = { unusedparams = true },
            staticcheck = true,
            gofumpt = true,
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        },
      },

      -- JavaScript/TypeScript
      ts_ls = {
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = 'all',
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = 'all',
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
        },
      },

      -- C#
      omnisharp = {
        cmd = { 'omnisharp', '--languageserver', '--hostPID', tostring(vim.fn.getpid()) },
        settings = {
          FormattingOptions = { EnableEditorConfigSupport = true, OrganizeImports = true },
          MsBuild = { LoadProjectsOnDemand = nil },
          RoslynExtensionsOptions = { EnableAnalyzersSupport = nil, EnableImportCompletion = nil, AnalyzeOpenDocumentsOnly = nil },
          Sdk = { IncludePrereleases = true },
        },
      },

      -- Zig
      zls = {
        settings = {
          zls = {
            enable_inlay_hints = true,
            enable_snippets = true,
            warn_style = true,
          },
        },
      },

      -- Kotlin
      kotlin_language_server = {
        settings = {
          kotlin = {
            compiler = { jvm = { target = '11' } },
          },
        },
      },

      -- Web Technologies
      jsonls = {},
      sqlls = {},
      terraformls = {},
      yamlls = {},
      bashls = {},
      dockerls = {},
      docker_compose_language_service = {},
      html = { filetypes = { 'html', 'twig', 'hbs' } },
    }

    -- List of language servers to install via mason-lspconfig
    local lsp_servers_to_install = vim.tbl_keys(servers)

    -- List of other tools (formatters, linters) to install via mason-tool-installer
    local other_tools_to_install = {
      'stylua',
      'rustfmt',
      'clang-format',
      'google-java-format',
      'gofumpt',
      'prettier',
      'black',
      'isort',
    }

    -- Setup mason-tool-installer to handle all the formatters/linters
    require('mason-tool-installer').setup { ensure_installed = other_tools_to_install }

    -- Configure and enable servers using mason-lspconfig
    require('mason-lspconfig').setup({
      ensure_installed = lsp_servers_to_install,
      handlers = {
        function(server_name)
          local opts = {
            capabilities = capabilities,
          }
          -- Apply custom server configurations if they exist
          if servers[server_name] then
            opts = vim.tbl_deep_extend("force", opts, servers[server_name])
          end
          require('lspconfig')[server_name].setup(opts)
        end,
      },
    })
  end,
}

