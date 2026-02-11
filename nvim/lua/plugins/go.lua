return {
  -- Go development enhancements
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup({
        disable_defaults = false,
        go = "go", -- go command
        goimports = "gopls", -- goimports command, can be gopls[default] or goimports
        fillstruct = "gopls", -- can be nil (use fillstruct, slower) and gopls
        gofmt = "gofumpt", -- gofmt cmd
        max_line_len = 120,
        tag_transform = false,
        test_dir = "",
        comment_placeholder = "  ",
        lsp_cfg = false, -- false: use your own lspconfig
        lsp_gofumpt = true,
        lsp_on_attach = false, -- use on_attach from lspconfig
        dap_debug = true,
        
        -- Go struct tags
        lsp_document_formatting = false,
        
        -- Go code lens
        lsp_codelens = true,
        
        -- Inlay hints
        lsp_inlay_hints = {
          enable = true,
          only_current_line = false,
          only_current_line_autocmd = "CursorHold",
          show_variable_name = true,
          parameter_hints_prefix = " ",
          show_parameter_hints = true,
          other_hints_prefix = "=> ",
          max_len_align = false,
          max_len_align_padding = 1,
          right_align = false,
          right_align_padding = 7,
          highlight = "Comment",
        },
      })
      
      -- Go-specific keymaps
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "go",
        callback = function()
          vim.keymap.set("n", "<leader>gf", "<cmd>GoFillStruct<cr>", { desc = "Fill Struct", buffer = true })
          vim.keymap.set("n", "<leader>ge", "<cmd>GoIfErr<cr>", { desc = "Generate if err", buffer = true })
          vim.keymap.set("n", "<leader>gt", "<cmd>GoAddTags<cr>", { desc = "Add Tags", buffer = true })
          vim.keymap.set("n", "<leader>gT", "<cmd>GoRmTags<cr>", { desc = "Remove Tags", buffer = true })
          vim.keymap.set("n", "<leader>gi", "<cmd>GoImpl<cr>", { desc = "Implement Interface", buffer = true })
          vim.keymap.set("n", "<leader>gm", "<cmd>GoModTidy<cr>", { desc = "Go Mod Tidy", buffer = true })
        end,
      })
      
      -- Auto import on save
      local format_sync_grp = vim.api.nvim_create_augroup("GoImport", {})
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.go",
        callback = function()
          require("go.format").goimports()
        end,
        group = format_sync_grp,
      })
    end,
    event = { "CmdlineEnter" },
    ft = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()',
  },
}
