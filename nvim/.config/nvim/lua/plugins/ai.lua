return {
  ------------------------------------------------------------------
  -- GitHub Copilot (inline suggestions)
  ------------------------------------------------------------------
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      local copilot = require("copilot")
      local suggestion = require("copilot.suggestion")

      copilot.setup({
        suggestion = {
          enabled = true,
          auto_trigger = false,
          debounce = 75,
          keymap = {
            accept = false,
            accept_word = false,
            accept_line = false,
            next = false,
            prev = false,
            dismiss = false,
          },
        },
        panel = { enabled = false },
      })

      -- Keep inline suggestions readable regardless of colorscheme defaults.
      vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = "#7aa2f7", italic = true })
      vim.api.nvim_set_hl(0, "CopilotAnnotation", { fg = "#7aa2f7" })

      local inline_enabled = false

      local function notify_status()
        local status = inline_enabled and "enabled" or "disabled"
        vim.notify("Copilot inline suggestions " .. status, vim.log.levels.INFO)
      end

      local function with_inline_enabled(fn)
        return function()
          if not inline_enabled then
            return
          end
          fn()
        end
      end

      local function toggle_inline()
        inline_enabled = not inline_enabled
        if not inline_enabled then
          suggestion.dismiss()
        end
        notify_status()
      end

      vim.keymap.set({ "i", "n" }, "<M-j>", toggle_inline, { desc = "Toggle Copilot inline" })
      vim.keymap.set({ "i", "n" }, "<C-g>j", toggle_inline, { desc = "Toggle Copilot inline (reliable)" })
      vim.keymap.set("n", "<leader>ai", toggle_inline, { desc = "AI toggle inline" })

      vim.keymap.set("i", "<M-k>", with_inline_enabled(function()
        suggestion.next()
      end), { desc = "Copilot next suggestion" })
      vim.keymap.set("i", "<C-g>k", with_inline_enabled(function()
        suggestion.next()
      end), { desc = "Copilot next suggestion (reliable)" })

      vim.keymap.set("i", "<M-h>", with_inline_enabled(function()
        suggestion.prev()
      end), { desc = "Copilot previous suggestion" })
      vim.keymap.set("i", "<C-g>h", with_inline_enabled(function()
        suggestion.prev()
      end), { desc = "Copilot previous suggestion (reliable)" })

      vim.keymap.set("i", "<M-l>", with_inline_enabled(function()
        suggestion.accept()
      end), { desc = "Copilot accept suggestion" })
      vim.keymap.set("i", "<C-g>l", with_inline_enabled(function()
        suggestion.accept()
      end), { desc = "Copilot accept suggestion (reliable)" })

      vim.keymap.set("n", "<leader>ak", function()
        vim.cmd("startinsert")
        suggestion.next()
      end, { desc = "AI next inline suggestion" })

      vim.keymap.set("n", "<leader>ah", function()
        vim.cmd("startinsert")
        suggestion.prev()
      end, { desc = "AI previous inline suggestion" })
    end,
  },

  ------------------------------------------------------------------
  -- Copilot Chat (supports selecting available GitHub Copilot models)
  ------------------------------------------------------------------
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    opts = {
      provider = "copilot",
      model = "gpt-4.1",
      auto_insert_mode = true,
      question_header = "## User ",
      answer_header = "## Copilot ",
      -- Wide vertical split so long streaming responses aren't clipped
      window = {
        layout = "vertical",
        width = 0.45,
      },
      providers = {
        copilot = {
          disabled = false,
        },
      },
    },
    config = function(_, opts)
      local chat = require("CopilotChat")
      chat.setup(opts)

      vim.keymap.set({ "n", "v" }, "<leader>aa", function()
        chat.toggle()
      end, { desc = "AI Chat Toggle" })

      vim.keymap.set({ "n", "v" }, "<leader>ap", function()
        chat.open()
      end, { desc = "AI Chat Prompt" })

      vim.keymap.set("n", "<leader>am", "<cmd>CopilotChatModels<cr>", { desc = "AI Select Model" })
      vim.keymap.set("n", "<leader>ac", "<cmd>CopilotChat<cr>", { desc = "AI Chat (ask)" })
      vim.keymap.set("n", "<leader>aR", "<cmd>CopilotChatReset<cr>", { desc = "AI Chat reset" })
      vim.keymap.set("n", "<leader>aS", "<cmd>CopilotChatStop<cr>", { desc = "AI Chat stop" })

      vim.keymap.set({ "n", "v" }, "<leader>aq", function()
        vim.ui.input({ prompt = "Ask Copilot: " }, function(input)
          if input and input ~= "" then
            chat.ask(input)
          end
        end)
      end, { desc = "AI quick ask" })
    end,
  },

  ------------------------------------------------------------------
  -- Avante (Cursor-like inline diffs + file editing)
  ------------------------------------------------------------------
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false,
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      -- Optional: richer markdown rendering in the chat panel
      { "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown", "Avante" } },
    },
    opts = {
      provider = "copilot",
      -- Avoid collisions with CopilotChat (<leader>aa/ar) and copilot.lua (<leader>ah, <M-l>)
      mappings = {
        ask = "<leader>aA",
        edit = "<leader>ae",
        refresh = "<leader>aX",
        focus = "<leader>af",
        toggle = {
          default = "<leader>at",
          debug = "<leader>aD",
          hint = "<leader>aH",
          suggestion = "<leader>aTs",
          repomap = "<leader>aTm",
        },
        -- remap avante's suggestion keys away from copilot.lua's <M-l>, <M-k>, <M-h>
        suggestion = {
          accept = "<M-CR>",
          next = "<M-n>",
          prev = "<M-p>",
          dismiss = "<M-e>",
        },
      },
    },
  },
}
