return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      
      -- Configure gopls
      vim.lsp.config("gopls", {
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

      vim.lsp.enable("gopls")

      -- Configure lua_ls for Neovim development
      vim.lsp.config("lua_ls", {
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
      
      vim.lsp.enable("lua_ls")

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

