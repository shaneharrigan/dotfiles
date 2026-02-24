return {
  -- Rust development enhancements
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    ft = { "rust" },
    config = function()
      vim.g.rustaceanvim = {
        -- Plugin configuration
        tools = {},
        -- LSP configuration
        server = {
          on_attach = function(client, bufnr)
            -- Enable inlay hints if supported
            if client.server_capabilities.inlayHintProvider then
              vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            end
          end,
          default_settings = {
            -- rust-analyzer language server configuration
            ["rust-analyzer"] = {},
          },
        },
        -- DAP configuration
        dap = {},
      }
      
      -- Rust-specific keymaps
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "rust",
        callback = function(args)
          local bufnr = args.buf
          
          -- Rustacean commands
          vim.keymap.set("n", "<leader>rr", function()
            vim.cmd.RustLsp("runnables")
          end, { desc = "Rust Runnables", buffer = bufnr })
          
          vim.keymap.set("n", "<leader>rd", function()
            vim.cmd.RustLsp("debuggables")
          end, { desc = "Rust Debuggables", buffer = bufnr })
          
          vim.keymap.set("n", "<leader>rt", function()
            vim.cmd.RustLsp("testables")
          end, { desc = "Rust Tests", buffer = bufnr })
          
          vim.keymap.set("n", "<leader>re", function()
            vim.cmd.RustLsp("expandMacro")
          end, { desc = "Expand Macro", buffer = bufnr })
          
          vim.keymap.set("n", "<leader>rc", function()
            vim.cmd.RustLsp("openCargo")
          end, { desc = "Open Cargo.toml", buffer = bufnr })
          
          vim.keymap.set("n", "<leader>rp", function()
            vim.cmd.RustLsp("parentModule")
          end, { desc = "Parent Module", buffer = bufnr })
          
          vim.keymap.set("n", "<leader>rj", function()
            vim.cmd.RustLsp("joinLines")
          end, { desc = "Join Lines", buffer = bufnr })
          
          vim.keymap.set("n", "<leader>rm", function()
            vim.cmd.RustLsp { "moveItem", "up" }
          end, { desc = "Move Item Up", buffer = bufnr })
          
          vim.keymap.set("n", "<leader>rM", function()
            vim.cmd.RustLsp { "moveItem", "down" }
          end, { desc = "Move Item Down", buffer = bufnr })
          
          vim.keymap.set("n", "<leader>rh", function()
            vim.cmd.RustLsp { "hover", "actions" }
          end, { desc = "Hover Actions", buffer = bufnr })
          
          vim.keymap.set("n", "<leader>rg", function()
            vim.cmd.RustLsp("crateGraph")
          end, { desc = "Crate Graph", buffer = bufnr })
          
          vim.keymap.set("n", "<leader>rx", function()
            vim.cmd.RustLsp("explainError")
          end, { desc = "Explain Error", buffer = bufnr })
          
          vim.keymap.set("n", "<leader>rD", function()
            vim.cmd.RustLsp("renderDiagnostic")
          end, { desc = "Render Diagnostic", buffer = bufnr })
          
          -- Quick cargo commands
          vim.keymap.set("n", "<leader>rb", function()
            vim.cmd("!cargo build")
          end, { desc = "Cargo Build", buffer = bufnr })
          
          vim.keymap.set("n", "<leader>rR", function()
            vim.cmd("!cargo run")
          end, { desc = "Cargo Run", buffer = bufnr })
          
          vim.keymap.set("n", "<leader>rT", function()
            vim.cmd("!cargo test")
          end, { desc = "Cargo Test", buffer = bufnr })
          
          vim.keymap.set("n", "<leader>rC", function()
            vim.cmd("!cargo check")
          end, { desc = "Cargo Check", buffer = bufnr })
          
          vim.keymap.set("n", "<leader>rcl", function()
            vim.cmd("!cargo clippy")
          end, { desc = "Cargo Clippy", buffer = bufnr })
        end,
      })
    end,
  },
  
  -- Crates.io integration
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("crates").setup({
        lsp = {
          enabled = true,
          actions = true,
          completion = true,
          hover = true,
        },
      })
      
      -- Crates.nvim keymaps (only in Cargo.toml)
      vim.api.nvim_create_autocmd("BufRead", {
        pattern = "Cargo.toml",
        callback = function()
          vim.keymap.set("n", "<leader>cu", function()
            require("crates").upgrade_crate()
          end, { desc = "Update Crate", buffer = true })
          
          vim.keymap.set("n", "<leader>cU", function()
            require("crates").upgrade_all_crates()
          end, { desc = "Update All Crates", buffer = true })
          
          vim.keymap.set("n", "<leader>ch", function()
            require("crates").open_homepage()
          end, { desc = "Crate Homepage", buffer = true })
          
          vim.keymap.set("n", "<leader>cd", function()
            require("crates").open_documentation()
          end, { desc = "Crate Docs", buffer = true })
          
          vim.keymap.set("n", "<leader>cr", function()
            require("crates").open_repository()
          end, { desc = "Crate Repository", buffer = true })
        end,
      })
    end,
  },
}
