return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local function setup_server(name, opts)
        if type(vim.lsp.config) == "function" then
          local ok_config = pcall(vim.lsp.config, name, opts)
          if not ok_config then
            return false
          end

          if type(vim.lsp.enable) == "function" then
            local ok_enable = pcall(vim.lsp.enable, name)
            return ok_enable
          end

          if type(vim.lsp.start) == "function" and opts.filetypes then
            local group = vim.api.nvim_create_augroup("manual-lsp-" .. name, { clear = true })
            vim.api.nvim_create_autocmd("FileType", {
              group = group,
              pattern = opts.filetypes,
              callback = function(args)
                local bufnr = args.buf
                local fname = vim.api.nvim_buf_get_name(bufnr)
                local root = opts.root_dir and opts.root_dir(fname) or vim.fs.dirname(fname)
                local start_opts = vim.tbl_deep_extend("force", {}, opts, {
                  name = name,
                  root_dir = root,
                })
                start_opts.filetypes = nil
                vim.lsp.start(start_opts, { bufnr = bufnr })
              end,
            })
            return true
          end

          return true
        end

        if type(vim.lsp.start) == "function" and opts.filetypes then
          local group = vim.api.nvim_create_augroup("legacy-manual-lsp-" .. name, { clear = true })
          vim.api.nvim_create_autocmd("FileType", {
            group = group,
            pattern = opts.filetypes,
            callback = function(args)
              local bufnr = args.buf
              local fname = vim.api.nvim_buf_get_name(bufnr)
              local root = opts.root_dir and opts.root_dir(fname) or vim.fs.dirname(fname)
              local start_opts = vim.tbl_deep_extend("force", {}, opts, {
                name = name,
                root_dir = root,
              })
              start_opts.filetypes = nil
              vim.lsp.start(start_opts, { bufnr = bufnr })
            end,
          })
          return true
        end

        return false
      end

      local function find_root(fname, patterns)
        local found = vim.fs.find(patterns, { upward = true, path = fname })
        if found and #found > 0 then
          return vim.fs.dirname(found[1])
        end
        return nil
      end

      local function root_or_file(fname, patterns)
        local root = find_root(fname, patterns)
        if root then
          return root
        end
        return vim.fs.dirname(fname)
      end
      
      -- Configure gopls
      setup_server("gopls", {
        capabilities = capabilities,
        settings = {
          gopls = {
            gofumpt = true,
            codelenses = {
              gc_details = false,
              generate = true,
              regenerate_cgo = true,
              run_govulncheck = true,
              test = true,
              tidy = true,
              upgrade_dependency = true,
              vendor = true,
            },
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
            analyses = {
              nilness = true,
              unusedparams = true,
              unusedwrite = true,
              useany = true,
            },
            usePlaceholders = true,
            completeUnimported = true,
            staticcheck = true,
            directoryFilters = {
              "-.git",
              "-.vscode",
              "-.idea",
              "-.vscode-test",
              "-node_modules",
            },
            semanticTokens = true,
          },
        },
      })

      -- Configure lua_ls for Neovim development
      setup_server("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME,
              },
            },
            diagnostics = {
              globals = { "vim" },
            },
            telemetry = { enable = false },
          },
        },
      })

      -- Configure TypeScript/JavaScript/React (support ts_ls and legacy tsserver names)
      local ts_lsp_config = {
        capabilities = capabilities,
        cmd = { "typescript-language-server", "--stdio" },
        filetypes = {
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
        },
        root_dir = function(fname)
          return root_or_file(fname, { "tsconfig.json", "jsconfig.json", "package.json", ".git" })
        end,
        single_file_support = true,
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = true,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = true,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
            },
          },
        },
      }

      if not setup_server("ts_ls", ts_lsp_config) then
        setup_server("tsserver", ts_lsp_config)
      end

      -- Configure html for HTML files
      setup_server("html", {
        capabilities = capabilities,
        cmd = { "vscode-html-language-server", "--stdio" },
        filetypes = { "html" },
        root_dir = function(fname)
          return root_or_file(fname, { "package.json", ".git" })
        end,
        single_file_support = true,
      })

      -- Configure pyright for Python
      setup_server("pyright", {
        capabilities = capabilities,
        cmd = { "pyright-langserver", "--stdio" },
        root_dir = function(fname)
          return root_or_file(fname, { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" })
        end,
        single_file_support = true,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
              typeCheckingMode = "basic",
            },
          },
        },
      })
      
      -- Configure clangd for C/C++
      setup_server("clangd", {
        capabilities = capabilities,
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
        },
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
      })
      
      -- Note: rust-analyzer is configured by rustaceanvim plugin

      ------------------------------------------------------------------
      -- LSP Keymaps and UI Configuration
      ------------------------------------------------------------------
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          local bufnr = args.buf
          
          -- gopls semantic tokens workaround
          if client and client.name == "gopls" then
            if not client.server_capabilities.semanticTokensProvider then
              local semantic = client.config.capabilities.textDocument.semanticTokens
              client.server_capabilities.semanticTokensProvider = {
                full = true,
                legend = {
                  tokenTypes = semantic.tokenTypes,
                  tokenModifiers = semantic.tokenModifiers,
                },
                range = true,
              }
            end
          end
          
          -- Enable inlay hints if supported
          if client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          end
          
          -- LSP Keymaps
          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
          end
          
          map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
          map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
          map("n", "gr", vim.lsp.buf.references, "References")
          map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
          map("n", "gt", vim.lsp.buf.type_definition, "Type Definition")
          map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
          map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
          map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
          map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
          map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
          map("v", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
          map("n", "<leader>lf", function()
            vim.lsp.buf.format({ async = true })
          end, "Format Buffer")
          map("n", "[d", vim.diagnostic.goto_prev, "Previous Diagnostic")
          map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
          map("n", "<leader>ld", vim.diagnostic.open_float, "Line Diagnostics")
          map("n", "<leader>lq", vim.diagnostic.setloclist, "Quickfix Diagnostics")
        end,
      })
      
      -- Configure diagnostics UI
      vim.diagnostic.config({
        virtual_text = {
          prefix = "●",
          spacing = 4,
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = " ",
            [vim.diagnostic.severity.INFO] = " ",
          },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })
    end,
  },
}

