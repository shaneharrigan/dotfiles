return {

  ------------------------------------------------------------------
  -- Telescope (fuzzy finder)
  ------------------------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { 
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    cmd = "Telescope",
    config = function()
      require("telescope").setup({
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          path_display = { "truncate" },
          file_ignore_patterns = { "node_modules", ".git/", "target/" },
          mappings = {
            i = {
              ["<C-j>"] = require("telescope.actions").move_selection_next,
              ["<C-k>"] = require("telescope.actions").move_selection_previous,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      })
      
      -- Load extensions
      pcall(require("telescope").load_extension, "fzf")
    end,
  },

  ------------------------------------------------------------------
  -- File Tree
  ------------------------------------------------------------------
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { 
          width = 30,
          side = "left",
        },
        renderer = { 
          group_empty = true,
          icons = {
            show = {
              git = true,
              folder = true,
              file = true,
              folder_arrow = true,
            },
          },
        },
        filters = { 
          dotfiles = false,
          custom = { ".git", "node_modules", ".cache" },
        },
        git = {
          enable = true,
          ignore = false,
        },
        actions = {
          open_file = {
            quit_on_open = false,
          },
        },
      })
    end,
  },

  ------------------------------------------------------------------
  -- Statusline
  ------------------------------------------------------------------
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
          section_separators = "",
          component_separators = "",
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  ------------------------------------------------------------------
  -- Git signs
  ------------------------------------------------------------------
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
          untracked = { text = "┆" },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          
          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end
          
          -- Navigation
          map("n", "]c", function()
            if vim.wo.diff then return "]c" end
            vim.schedule(function() gs.next_hunk() end)
            return "<Ignore>"
          end, { expr = true, desc = "Next hunk" })
          
          map("n", "[c", function()
            if vim.wo.diff then return "[c" end
            vim.schedule(function() gs.prev_hunk() end)
            return "<Ignore>"
          end, { expr = true, desc = "Previous hunk" })
          
          -- Actions
          map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
          map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
          map("v", "<leader>hs", function() gs.stage_hunk({vim.fn.line("."), vim.fn.line("v")}) end, { desc = "Stage hunk" })
          map("v", "<leader>hr", function() gs.reset_hunk({vim.fn.line("."), vim.fn.line("v")}) end, { desc = "Reset hunk" })
          map("n", "<leader>hS", gs.stage_buffer, { desc = "Stage buffer" })
          map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
          map("n", "<leader>hR", gs.reset_buffer, { desc = "Reset buffer" })
          map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
          map("n", "<leader>hb", function() gs.blame_line({full=true}) end, { desc = "Blame line" })
          map("n", "<leader>hd", gs.diffthis, { desc = "Diff this" })
        end,
      })
    end,
  },

  ------------------------------------------------------------------
  -- LazyGit integration
  ------------------------------------------------------------------
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "LazyGit",
  },

  ------------------------------------------------------------------
  -- Formatter
  ------------------------------------------------------------------
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          go = { "gofumpt", "goimports" },
          java = { "google-java-format" },
          lua = { "stylua" },
          json = { "prettier" },
          yaml = { "prettier" },
          markdown = { "prettier" },
          javascript = { "prettier" },
          typescript = { "prettier" },
        },
        format_on_save = {
          timeout_ms = 1000,
          lsp_fallback = true,
        },
      })
    end,
  },
  
  ------------------------------------------------------------------
  -- Linter
  ------------------------------------------------------------------
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      
      lint.linters_by_ft = {
        go = { "golangcilint" },
        java = { "checkstyle" },
      }
      
      -- Auto-lint on save and on text changed
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
  
  ------------------------------------------------------------------
  -- Testing support
  ------------------------------------------------------------------
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-go",
      "rcasia/neotest-java",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-go")({
            experimental = {
              test_table = true,
            },
            args = { "-count=1", "-timeout=60s" }
          }),
          require("neotest-java")({
            ignore_wrapper = false,
          }),
        },
        icons = {
          passed = "✓",
          failed = "✗",
          running = "⟳",
          skipped = "⊘",
          unknown = "?",
        },
      })
      
      -- Test keymaps
      vim.keymap.set("n", "<leader>tt", function() require("neotest").run.run() end, { desc = "Test Nearest" })
      vim.keymap.set("n", "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, { desc = "Test File" })
      vim.keymap.set("n", "<leader>ts", function() require("neotest").summary.toggle() end, { desc = "Test Summary" })
      vim.keymap.set("n", "<leader>to", function() require("neotest").output.open({ enter = true }) end, { desc = "Test Output" })
      vim.keymap.set("n", "<leader>tO", function() require("neotest").output_panel.toggle() end, { desc = "Test Output Panel" })
      vim.keymap.set("n", "<leader>tS", function() require("neotest").run.stop() end, { desc = "Stop Test" })
    end,
  },
  
  ------------------------------------------------------------------
  -- Code Actions UI
  ------------------------------------------------------------------
  {
    "aznhe21/actions-preview.nvim",
    config = function()
      require("actions-preview").setup({
        telescope = {
          sorting_strategy = "ascending",
          layout_strategy = "vertical",
          layout_config = {
            width = 0.8,
            height = 0.9,
            prompt_position = "top",
            preview_cutoff = 20,
            preview_height = function(_, _, max_lines)
              return max_lines - 15
            end,
          },
        },
      })
      
      -- Override default code action keymap
      vim.keymap.set({ "v", "n" }, "<leader>ca", require("actions-preview").code_actions, { desc = "Code Action" })
    end,
  },
  
  ------------------------------------------------------------------
  -- Which-key (shows keybindings)
  ------------------------------------------------------------------
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({
        plugins = {
          marks = true,
          registers = true,
          spelling = {
            enabled = true,
            suggestions = 20,
          },
          presets = {
            operators = true,
            motions = true,
            text_objects = true,
            windows = true,
            nav = true,
            z = true,
            g = true,
          },
        },
        win = {
          border = "rounded",
        },
      })
      
      -- Register which-key groups
      wk.add({
        { "<leader>b", group = "Buffer" },
        { "<leader>c", group = "Code" },
        { "<leader>d", group = "Debug" },
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git" },
        { "<leader>h", group = "Hunk" },
        { "<leader>l", group = "LSP" },
        { "<leader>q", group = "Quit" },
        { "<leader>t", group = "Test" },
        { "<leader>x", group = "Diagnostics" },
      })
    end,
  },
  
  ------------------------------------------------------------------
  -- Trouble (better diagnostics list)
  ------------------------------------------------------------------
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    config = function()
      require("trouble").setup({})
      
      vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
      vim.keymap.set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer Diagnostics (Trouble)" })
      vim.keymap.set("n", "<leader>xl", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List (Trouble)" })
      vim.keymap.set("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List (Trouble)" })
    end,
  },
  
  ------------------------------------------------------------------
  -- Auto-pairs
  ------------------------------------------------------------------
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({
        check_ts = true,
        ts_config = {
          lua = { "string" },
          javascript = { "template_string" },
          java = false,
        },
      })
      
      -- Integration with nvim-cmp
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },
  
  ------------------------------------------------------------------
  -- Comment
  ------------------------------------------------------------------
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },
  
  ------------------------------------------------------------------
  -- Indent guides
  ------------------------------------------------------------------
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup({
        indent = {
          char = "│",
          tab_char = "│",
        },
        scope = { enabled = false },
        exclude = {
          filetypes = {
            "help",
            "alpha",
            "dashboard",
            "neo-tree",
            "Trouble",
            "lazy",
            "mason",
          },
        },
      })
    end,
  },
}


