return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "gopls",                           -- Go
          "jdtls",                           -- Java
          "ts_ls",                           -- JavaScript/TypeScript
          "pyright",                         -- Python
          "html",                            -- HTML
          "cssls",                           -- CSS
          "clangd",                          -- C/C++
          "rust_analyzer",                   -- Rust
          "clojure_lsp",                     -- Clojure/ClojureScript
          "lua_ls",                          -- Lua
          "jsonls",                          -- JSON
          "yamlls",                          -- YAML
          "marksman",                        -- Markdown
          "bashls",                          -- Bash/Zsh
          "dockerls",                        -- Dockerfile
          "docker_compose_language_service", -- Docker Compose
        },
        automatic_installation = true,
        automatic_enable = false,
      })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          -- Go tools
          "gopls",
          "gofumpt",
          "goimports",
          "gomodifytags",
          "impl",
          "delve",           -- Go debugger
          
          -- Java tools
          "jdtls",
          "google-java-format",
          "java-debug-adapter",
          "java-test",

          -- JavaScript/TypeScript/HTML tools
          "typescript-language-server",
          "css-lsp",
          "eslint_d",

          -- Python tools
          "pyright",
          "ruff",
          "black",
          "isort",
          "debugpy",
          
          -- C/C++ tools
          "clangd",
          "clang-format",
          "codelldb",        -- C/C++/Rust debugger
          
          -- Rust tools
          "rust-analyzer",
          "rustfmt",

          -- Clojure/ClojureScript tools
          "clojure-lsp",
          "clj-kondo",
          "zprint",

          -- Shell/Docker tools
          "bash-language-server",
          "shfmt",
          "shellcheck",
          "dockerfile-language-server",
          "docker-compose-language-service",
          "hadolint",

          -- Daily-use config/docs tools
          "lua-language-server",
          "stylua",
          "json-lsp",
          "yaml-language-server",
          "marksman",
          "prettier",
          
          -- Linters
          "golangci-lint",
          "checkstyle",

        },
        auto_update = true,
        run_on_start = true,
      })
    end,
  },
}
