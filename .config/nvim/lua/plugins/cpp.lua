return {
  -- C/C++ development enhancements
  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp", "objc", "objcpp", "cuda" },
    config = function()
      require("clangd_extensions").setup({
        inlay_hints = {
          inline = vim.fn.has("nvim-0.10") == 1,
          only_current_line = false,
          only_current_line_autocmd = "CursorHold",
          show_parameter_hints = true,
          parameter_hints_prefix = " ",
          other_hints_prefix = "=> ",
          max_len_align = false,
          max_len_align_padding = 1,
          right_align = false,
          right_align_padding = 7,
          highlight = "Comment",
          priority = 100,
        },
        ast = {
          role_icons = {
            type = "",
            declaration = "",
            expression = "",
            specifier = "",
            statement = "",
            ["template argument"] = "",
          },
          kind_icons = {
            Compound = "",
            Recovery = "",
            TranslationUnit = "",
            PackExpansion = "",
            TemplateTypeParm = "",
            TemplateTemplateParm = "",
            TemplateParamObject = "",
          },
        },
        memory_usage = {
          border = "rounded",
        },
        symbol_info = {
          border = "rounded",
        },
      })
      
      -- C/C++ specific keymaps
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "c", "cpp", "objc", "objcpp" },
        callback = function(args)
          local buf = args.buf
          
          vim.keymap.set("n", "<leader>ch", function()
            vim.cmd("ClangdSwitchSourceHeader")
          end, { desc = "Switch Source/Header", buffer = buf })
          
          vim.keymap.set("n", "<leader>cs", function()
            vim.cmd("ClangdSymbolInfo")
          end, { desc = "Symbol Info", buffer = buf })
          
          vim.keymap.set("n", "<leader>ct", function()
            vim.cmd("ClangdTypeHierarchy")
          end, { desc = "Type Hierarchy", buffer = buf })
          
          vim.keymap.set("n", "<leader>cm", function()
            vim.cmd("ClangdMemoryUsage")
          end, { desc = "Memory Usage", buffer = buf })
          
          vim.keymap.set("n", "<leader>ca", function()
            vim.cmd("ClangdAST")
          end, { desc = "View AST", buffer = buf })
        end,
      })
    end,
  },
  
  -- CMake integration
  {
    "Civitasv/cmake-tools.nvim",
    ft = { "c", "cpp", "cmake" },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("cmake-tools").setup({
        cmake_command = "cmake",
        ctest_command = "ctest",
        cmake_regenerate_on_save = false,
        cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
        cmake_build_options = {},
        cmake_build_directory = "build/${variant:buildType}",
        cmake_soft_link_compile_commands = true,
        cmake_compile_commands_from_lsp = false,
        cmake_kits_path = nil,
        cmake_variants_message = {
          short = { show = true },
          long = { show = true, max_length = 40 },
        },
        cmake_dap_configuration = {
          name = "cpp",
          type = "codelldb",
          request = "launch",
          stopOnEntry = false,
          runInTerminal = true,
          console = "integratedTerminal",
        },
        cmake_executor = {
          name = "quickfix",
          opts = {},
          default_opts = {
            quickfix = {
              show = "always",
              position = "belowright",
              size = 10,
              encoding = "utf-8",
              auto_close_when_success = true,
            },
          },
        },
        cmake_runner = {
          name = "terminal",
          opts = {},
          default_opts = {
            terminal = {
              name = "Main Terminal",
              prefix_name = "[CMakeTools]: ",
              split_direction = "horizontal",
              split_size = 11,
            },
          },
        },
        cmake_notifications = {
          runner = { enabled = true },
          executor = { enabled = true },
          spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
        },
      })
      
      -- CMake keymaps
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "c", "cpp", "cmake" },
        callback = function()
          vim.keymap.set("n", "<leader>cg", "<cmd>CMakeGenerate<cr>", { desc = "CMake Generate" })
          vim.keymap.set("n", "<leader>cb", "<cmd>CMakeBuild<cr>", { desc = "CMake Build" })
          vim.keymap.set("n", "<leader>cr", "<cmd>CMakeRun<cr>", { desc = "CMake Run" })
          vim.keymap.set("n", "<leader>cd", "<cmd>CMakeDebug<cr>", { desc = "CMake Debug" })
          vim.keymap.set("n", "<leader>cy", "<cmd>CMakeSelectBuildType<cr>", { desc = "CMake Select Build Type" })
          vim.keymap.set("n", "<leader>ct", "<cmd>CMakeSelectBuildTarget<cr>", { desc = "CMake Select Target" })
          vim.keymap.set("n", "<leader>cl", "<cmd>CMakeSelectLaunchTarget<cr>", { desc = "CMake Select Launch Target" })
          vim.keymap.set("n", "<leader>cC", "<cmd>CMakeClean<cr>", { desc = "CMake Clean" })
          vim.keymap.set("n", "<leader>cS", "<cmd>CMakeStop<cr>", { desc = "CMake Stop" })
        end,
      })
    end,
  },
}
