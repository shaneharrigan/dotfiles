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
      local go_ok, go = pcall(require, "go")
      if not go_ok then
        return
      end
      
      go.setup({
        disable_defaults = false,
        go = "go", -- go command
        goimports = "gopls", -- goimports command, can be gopls[default] or goimports
        fillstruct = "gopls", -- can be nil (use fillstruct, slower) and gopls
        gofmt = "gofumpt", -- gofmt cmd
        gofumpt = "gofumpt",
        max_line_len = 120,
        tag_transform = false,
        tag_options = "json=omitempty",
        tags_options = { "json", "yaml" },
        gotests_template = "",
        test_dir = "",
        comment_placeholder = "  ",
        lsp_cfg = false, -- false: use your own lspconfig
        lsp_gofumpt = true,
        lsp_on_attach = false, -- use on_attach from lspconfig
        dap_debug = true,
        trouble = false,
        run_in_floaterm = false,
        luasnip = false,
        
        -- Ensure gomodifytags is used
        gomodifytags = {
          transform = false,
        },
        
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
        callback = function(args)
          local buf = args.buf
          
          -- Use Lua API directly instead of commands
          vim.keymap.set("n", "<leader>gf", function()
            require("go.reftool").fillstruct()
          end, { desc = "Fill Struct", buffer = buf })
          
          vim.keymap.set("n", "<leader>ge", function()
            require("go.iferr").run()
          end, { desc = "Generate if err", buffer = buf })
          
          -- Direct gomodifytags call for better reliability
          vim.keymap.set("n", "<leader>gt", function()
            vim.ui.input({ prompt = "Add tags (e.g., json,yaml): " }, function(tags)
              if not tags or tags == "" then
                tags = "json"
              end
              
              -- Save the file without triggering autocommands
              vim.cmd("noautocmd write")
              
              local line = vim.fn.line(".")
              local file = vim.fn.expand("%:p")
              
              -- Call gomodifytags directly
              local cmd = string.format(
                "gomodifytags -file %s -line %d -add-tags %s -w",
                vim.fn.shellescape(file),
                line,
                tags
              )
              
              local result = vim.fn.system(cmd)
              if vim.v.shell_error == 0 then
                vim.cmd("edit!")
                vim.notify("Tags added successfully", vim.log.levels.INFO)
              else
                vim.notify("Error: " .. result, vim.log.levels.ERROR)
              end
            end)
          end, { desc = "Add Tags", buffer = buf })
          
          vim.keymap.set("v", "<leader>gt", function()
            vim.ui.input({ prompt = "Add tags (e.g., json,yaml): " }, function(tags)
              if not tags or tags == "" then
                tags = "json"
              end
              
              -- Save the file without triggering autocommands
              vim.cmd("noautocmd write")
              
              local start_line = vim.fn.line("'<")
              local end_line = vim.fn.line("'>")
              local file = vim.fn.expand("%:p")
              
              -- Call gomodifytags for range
              local cmd = string.format(
                "gomodifytags -file %s -line %d,%d -add-tags %s -w",
                vim.fn.shellescape(file),
                start_line,
                end_line,
                tags
              )
              
              local result = vim.fn.system(cmd)
              if vim.v.shell_error == 0 then
                vim.cmd("edit!")
                vim.notify("Tags added successfully", vim.log.levels.INFO)
              else
                vim.notify("Error: " .. result, vim.log.levels.ERROR)
              end
            end)
          end, { desc = "Add Tags", buffer = buf })
          
          vim.keymap.set("n", "<leader>gT", function()
            vim.ui.input({ prompt = "Remove tags (e.g., json,yaml): " }, function(tags)
              if not tags or tags == "" then
                tags = "json"
              end
              
              -- Save the file without triggering autocommands
              vim.cmd("noautocmd write")
              
              local line = vim.fn.line(".")
              local file = vim.fn.expand("%:p")
              
              -- Call gomodifytags to remove tags
              local cmd = string.format(
                "gomodifytags -file %s -line %d -remove-tags %s -w",
                vim.fn.shellescape(file),
                line,
                tags
              )
              
              local result = vim.fn.system(cmd)
              if vim.v.shell_error == 0 then
                vim.cmd("edit!")
                vim.notify("Tags removed successfully", vim.log.levels.INFO)
              else
                vim.notify("Error: " .. result, vim.log.levels.ERROR)
              end
            end)
          end, { desc = "Remove Tags", buffer = buf })
          
          vim.keymap.set("v", "<leader>gT", function()
            require("go.tags").rm()
          end, { desc = "Remove Tags", buffer = buf })
          
          vim.keymap.set("n", "<leader>gi", function()
            require("go.impl").run()
          end, { desc = "Implement Interface", buffer = buf })
          
          vim.keymap.set("n", "<leader>gm", function()
            require("go.gomod").tidy()
          end, { desc = "Go Mod Tidy", buffer = buf })
          
          vim.keymap.set("n", "<leader>gI", function()
            local format_ok, format = pcall(require, "go.format")
            if format_ok then
              format.goimports()
              vim.notify("Imports organized", vim.log.levels.INFO)
            end
          end, { desc = "Organize Imports", buffer = buf })
          
          vim.keymap.set("n", "<leader>gr", function()
            require("go.dap").run()
          end, { desc = "Go Run", buffer = buf })
          
          vim.keymap.set("n", "<leader>gb", function()
            require("go.dap").breakpt()
          end, { desc = "Go Debug Breakpoint", buffer = buf })
        end,
      })
      
      -- Auto import on save (disabled to allow adding libraries before they're built)
      -- local format_sync_grp = vim.api.nvim_create_augroup("GoImport", {})
      -- vim.api.nvim_create_autocmd("BufWritePre", {
      --   pattern = "*.go",
      --   callback = function()
      --     local format_ok, format = pcall(require, "go.format")
      --     if format_ok then
      --       format.goimports()
      --     end
      --   end,
      --   group = format_sync_grp,
      -- })
    end,
    event = { "CmdlineEnter" },
    ft = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()',
  },
}
