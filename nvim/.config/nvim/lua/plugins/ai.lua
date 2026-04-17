local codex_path = vim.fn.exepath("codex")
local cagent_path = vim.fn.exepath("cagent")
local default_cli_agent = codex_path ~= "" and "codex" or (cagent_path ~= "" and "cagent" or nil)
local copilot_chat_history_path = vim.fn.stdpath("data") .. "/copilotchat_history"
local resolved_codecompanion_copilot_model = "gpt-4.1"

local function resolve_codecompanion_copilot_model(adapter)
  if adapter and adapter.schema and adapter.schema.model and type(adapter.schema.model.choices) == "function" then
    local ok, choices = pcall(adapter.schema.model.choices, adapter, { async = false })
    if ok and type(choices) == "table" and not vim.tbl_isempty(choices) then
      local preferred_models = {
        "gpt-4.1",
        "gpt-4o",
        "claude-sonnet-4.5",
        "claude-3.7-sonnet",
        "o4-mini",
        "o3-mini",
      }

      for _, model in ipairs(preferred_models) do
        if choices[model] then
          resolved_codecompanion_copilot_model = model
          return model
        end
      end

      local available_models = vim.tbl_keys(choices)
      table.sort(available_models)
      resolved_codecompanion_copilot_model = available_models[1]
    end
  end

  return resolved_codecompanion_copilot_model
end

local function list_copilot_chat_histories()
  local files = vim.fn.globpath(copilot_chat_history_path, "*.json", false, true)
  local histories = {}

  for _, path in ipairs(files) do
    histories[#histories + 1] = vim.fn.fnamemodify(path, ":t:r")
  end

  table.sort(histories, function(a, b)
    return a > b
  end)

  return histories
end

local function save_copilot_chat_history()
  vim.ui.input({
    prompt = "Save Copilot chat as: ",
    default = os.date("%Y-%m-%d-%H%M%S"),
  }, function(input)
    if not input or input == "" then
      return
    end

    require("CopilotChat").save(input, copilot_chat_history_path)
  end)
end

local function load_copilot_chat_history()
  local histories = list_copilot_chat_histories()

  if vim.tbl_isempty(histories) then
    vim.notify("No saved Copilot chats found yet.", vim.log.levels.INFO)
    return
  end

  vim.ui.select(histories, {
    prompt = "Load Copilot chat history:",
  }, function(choice)
    if not choice or choice == "" then
      return
    end

    require("CopilotChat").load(choice, copilot_chat_history_path)
  end)
end

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
    cmd = { "CopilotChat", "CopilotChatModels", "CopilotChatReset", "CopilotChatStop" },
    keys = {
      {
        "<leader>aa",
        function()
          require("CopilotChat").toggle()
        end,
        desc = "AI Chat Toggle",
      },
      {
        "<leader>ap",
        function()
          require("CopilotChat").open()
        end,
        desc = "AI Chat Prompt",
      },
      { "<leader>am", "<cmd>CopilotChatModels<cr>", desc = "AI Select Model" },
      { "<leader>ac", "<cmd>CopilotChat<cr>", desc = "AI Chat (ask)" },
      { "<leader>aR", "<cmd>CopilotChatReset<cr>", desc = "AI Chat reset" },
      { "<leader>aS", "<cmd>CopilotChatStop<cr>", desc = "AI Chat stop" },
      {
        "<leader>as",
        save_copilot_chat_history,
        desc = "AI Save chat history",
      },
      {
        "<leader>aH",
        load_copilot_chat_history,
        desc = "AI Load chat history",
      },
      {
        "<leader>aq",
        function()
          vim.ui.input({ prompt = "Ask Copilot: " }, function(input)
            if input and input ~= "" then
              require("CopilotChat").ask(input)
            end
          end)
        end,
        desc = "AI quick ask",
      },
    },
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    opts = {
      provider = "copilot",
      model = "auto",
      auto_insert_mode = true,
      question_header = "## User ",
      answer_header = "## Copilot ",
      history_path = copilot_chat_history_path,
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
      require("CopilotChat").setup(opts)
    end,
  },

  ------------------------------------------------------------------
  -- CodeCompanion (agentic chat + inline edits)
  ------------------------------------------------------------------
  {
    "olimorris/codecompanion.nvim",
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions", "CodeCompanionCLI" },
    keys = {
      { "<leader>aA", "<cmd>CodeCompanionChat Toggle<cr>", desc = "AI Agent chat", mode = { "n", "v" } },
      { "<leader>aP", "<cmd>CodeCompanionActions<cr>", desc = "AI Action palette", mode = { "n", "v" } },
      { "<leader>ae", "<cmd>CodeCompanion<cr>", desc = "AI inline edit", mode = { "n", "v" } },
      { "<leader>an", "<cmd>CodeCompanionChat<cr>", desc = "AI new chat prompt", mode = { "n", "v" } },
      {
        "<leader>aL",
        function()
          if default_cli_agent == nil then
            vim.notify("No CodeCompanion CLI agent found. Install `codex` or `cagent`.", vim.log.levels.ERROR)
            return
          end
          vim.cmd("CodeCompanionCLI")
        end,
        desc = "AI CLI agent",
      },
      { "<leader>aF", "<cmd>CodeCompanion /finish-file<cr>", desc = "AI finish file", mode = { "n", "v" } },
      { "<leader>af", "<cmd>CodeCompanion /fix<cr>", desc = "AI fix selection", mode = "v" },
      { "<leader>ax", "<cmd>CodeCompanion /explain<cr>", desc = "AI explain selection", mode = "v" },
      { "<leader>at", "<cmd>CodeCompanion /tests<cr>", desc = "AI generate tests", mode = "v" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      display = {
        action_palette = {
          provider = "telescope",
          opts = {
            show_preset_prompts = false,
          },
        },
      },
      adapters = {
        http = {
          copilot = function()
            return require("codecompanion.adapters").extend("copilot", {
              schema = {
                model = {
                  default = resolve_codecompanion_copilot_model,
                },
              },
            })
          end,
        },
      },
      interactions = {
        chat = {
          adapter = "copilot",
          tools = {
            opts = {
              -- Load the built-in agent tool group in every chat buffer so the
              -- model can read/edit files and run approved commands by default.
              default_tools = { "agent" },
            },
            -- Avoid leaving Copilot chat requests mid-tool when common reads or
            -- command lookups require approval. File edits still use the plugin's
            -- diff/confirmation flow, so actual changes remain reviewable.
            ["read_file"] = {
              opts = {
                require_approval_before = false,
              },
            },
            ["grep_search"] = {
              opts = {
                require_approval_before = false,
              },
            },
            ["run_command"] = {
              opts = {
                require_approval_before = false,
                require_cmd_approval = false,
              },
            },
          },
          opts = {
            system_prompt = function(ctx)
              return ctx.default_system_prompt .. [[

Additional requirements for code edits:
- Always produce syntactically complete code. Never leave incomplete or truncated file endings.
- Close all opened blocks, tags, and delimiters.
- Preserve the file's existing style and indentation unless asked to change it.
- Ensure the final file ends with a single trailing newline.
]]
            end,
          },
        },
        inline = {
          adapter = "copilot",
        },
        cmd = {
          adapter = "copilot",
        },
        cli = {
          agent = default_cli_agent,
          agents = {
            codex = {
              cmd = codex_path ~= "" and codex_path or "codex",
              args = {},
              description = "OpenAI Codex CLI",
            },
            cagent = {
              cmd = cagent_path ~= "" and cagent_path or "cagent",
              args = {},
              description = "cagent CLI",
            },
          },
        },
      },
      prompt_library = {
        ["Finish File"] = {
          interaction = "inline",
          description = "Complete code cleanly through end-of-file",
          opts = {
            alias = "finish-file",
            auto_submit = true,
            modes = { "n", "v" },
            placement = "replace",
          },
          prompts = {
            {
              role = "system",
              content = [[
You are completing an in-editor code edit.
Always return syntactically complete output.
Never leave incomplete endings.
Close all opened blocks/tags/delimiters.
Preserve style and indentation.
Ensure a single trailing newline at EOF.
]],
            },
            {
              role = "user",
              content = "Finish and cleanly end this code without changing unrelated logic.",
            },
          },
        },
      },
    },
    config = function(_, opts)
      require("codecompanion").setup(opts)
    end,
  },
}
