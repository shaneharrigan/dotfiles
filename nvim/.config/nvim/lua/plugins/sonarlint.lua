return {
  {
    "schrieveslaach/sonarlint.nvim",
    ft = {
      "c",
      "cpp",
      "go",
      "java",
      "javascript",
      "javascriptreact",
      "python",
      "typescript",
      "typescriptreact",
    },
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    config = function()
      local data_dir = vim.fn.stdpath("data")
      local mason_bin = data_dir .. "/mason/bin/sonarlint-language-server"
      local mason_share = data_dir .. "/mason/share/sonarlint-analyzers"
      local analyzer_patterns = {
        "sonarcfamily.jar",
        "sonargo.jar",
        "sonarjava.jar",
        "sonarjs.jar",
        "sonarpython.jar",
        "sonartext.jar",
      }
      local analyzers = {}

      for _, pattern in ipairs(analyzer_patterns) do
        local matches = vim.fn.glob(mason_share .. "/" .. pattern, false, true)
        for _, match in ipairs(matches) do
          table.insert(analyzers, match)
        end
      end

      local server_cmd = vim.fn.executable(mason_bin) == 1 and mason_bin or "sonarlint-language-server"
      local root_markers = {
        ".git",
        "pom.xml",
        "build.gradle",
        "build.gradle.kts",
        "settings.gradle",
        "settings.gradle.kts",
        "go.mod",
        "package.json",
        "tsconfig.json",
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        "compile_commands.json",
        "Makefile",
      }

      if vim.fn.executable(server_cmd) ~= 1 then
        vim.notify(
          "SonarLint language server not found. Run :MasonInstall sonarlint-language-server",
          vim.log.levels.WARN
        )
        return
      end

      if #analyzers == 0 then
        vim.notify(
          "SonarLint analyzers not found under Mason share directory; diagnostics will stay disabled until they are installed.",
          vim.log.levels.WARN
        )
        return
      end

      require("sonarlint").setup({
        server = {
          cmd = vim.list_extend({ server_cmd, "-stdio", "-analyzers" }, analyzers),
        },
        filetypes = {
          "c",
          "cpp",
          "go",
          "java",
          "javascript",
          "javascriptreact",
          "python",
          "typescript",
          "typescriptreact",
        },
        root_dir = function(fname)
          local root = vim.fs.dirname(vim.fs.find(root_markers, {
            upward = true,
            path = vim.fs.dirname(fname),
          })[1] or "")

          if root == "." or root == "" then
            return vim.fs.dirname(fname)
          end

          return root
        end,
      })
    end,
  },
}
