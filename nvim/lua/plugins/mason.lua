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
          "gopls",      -- Go
          "jdtls",      -- Java
          "lua_ls",     -- Lua
        },
        automatic_installation = true,
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
          "java-debug-adapter",
          "java-test",
          
          -- Formatters
          "stylua",
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
