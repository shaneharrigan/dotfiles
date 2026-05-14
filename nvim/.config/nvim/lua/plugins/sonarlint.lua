return {
  {
    name = "sonarlint-lsp",
    dir = vim.fn.stdpath("config"),
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
      local filetypes = {
        "c",
        "cpp",
        "go",
        "java",
        "javascript",
        "javascriptreact",
        "python",
        "typescript",
        "typescriptreact",
      }
      local data_dir = vim.fn.stdpath("data")
      local mason_bin = data_dir .. "/mason/bin/sonarlint-language-server"
      local mason_share = data_dir .. "/mason/share/sonarlint-analyzers"
      local analyzers = vim.fn.glob(mason_share .. "/sonar*.jar", false, true)

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

      local function root_dir(fname)
        local root = vim.fs.dirname(vim.fs.find(root_markers, {
          upward = true,
          path = vim.fs.dirname(fname),
        })[1] or "")

        if root == "." or root == "" then
          return vim.fs.dirname(fname)
        end

        return root
      end

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

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      if ok_cmp then
        capabilities = cmp_lsp.default_capabilities(capabilities)
      end

      local cmd = vim.list_extend({ server_cmd, "-stdio", "-analyzers" }, analyzers)

      local function start_sonarlint(bufnr)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        if fname == "" then
          return
        end

        vim.lsp.start({
          name = "sonarlint",
          cmd = cmd,
          root_dir = root_dir(fname),
          capabilities = capabilities,
          settings = {
            sonarlint = {
              automaticAnalysis = true,
              disableTelemetry = true,
            },
          },
        }, { bufnr = bufnr })
      end

      local group = vim.api.nvim_create_augroup("sonarlint-lsp", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = filetypes,
        callback = function(args)
          start_sonarlint(args.buf)
        end,
      })

      if vim.tbl_contains(filetypes, vim.bo.filetype) then
        start_sonarlint(0)
      end
    end,
  },
}
