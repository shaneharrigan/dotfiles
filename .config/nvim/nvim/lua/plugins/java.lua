return {
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    config = function()
      -- Only run if we're actually in a Java file
      if vim.bo.filetype ~= "java" then
        return
      end
      
      local jdtls_ok, jdtls = pcall(require, "jdtls")
      if not jdtls_ok then
        vim.notify("nvim-jdtls not found", vim.log.levels.ERROR)
        return
      end
      
      -- Find jdtls installation path
      local jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
      
      -- Check if jdtls is actually installed
      if vim.fn.isdirectory(jdtls_path) == 0 then
        vim.notify("jdtls not installed. Run :MasonInstall jdtls", vim.log.levels.WARN)
        return
      end
      
      -- Data directory for workspace
      local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
      local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name
      
      -- OS-specific config
      local os_config = "linux"
      if vim.fn.has("mac") == 1 then
        os_config = "mac"
      elseif vim.fn.has("win32") == 1 then
        os_config = "win"
      end
      
      local config = {
        cmd = {
          "java",
          "-Declipse.application=org.eclipse.jdt.ls.core.id1",
          "-Dosgi.bundles.defaultStartLevel=4",
          "-Declipse.product=org.eclipse.jdt.ls.core.product",
          "-Dlog.protocol=true",
          "-Dlog.level=ALL",
          "-Xmx1g",
          "--add-modules=ALL-SYSTEM",
          "--add-opens", "java.base/java.util=ALL-UNNAMED",
          "--add-opens", "java.base/java.lang=ALL-UNNAMED",
          "-jar", vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
          "-configuration", jdtls_path .. "/config_" .. os_config,
          "-data", workspace_dir,
        },
        
        root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
        
        settings = {
          java = {
            eclipse = {
              downloadSources = true,
            },
            configuration = {
              updateBuildConfiguration = "interactive",
            },
            maven = {
              downloadSources = true,
            },
            implementationsCodeLens = {
              enabled = true,
            },
            referencesCodeLens = {
              enabled = true,
            },
            references = {
              includeDecompiledSources = true,
            },
            format = {
              enabled = true,
              settings = {
                url = vim.fn.stdpath("config") .. "/lang-servers/intellij-java-google-style.xml",
                profile = "GoogleStyle",
              },
            },
          },
          signatureHelp = { enabled = true },
          completion = {
            favoriteStaticMembers = {
              "org.hamcrest.MatcherAssert.assertThat",
              "org.hamcrest.Matchers.*",
              "org.hamcrest.CoreMatchers.*",
              "org.junit.jupiter.api.Assertions.*",
              "java.util.Objects.requireNonNull",
              "java.util.Objects.requireNonNullElse",
              "org.mockito.Mockito.*",
            },
          },
          contentProvider = { preferred = "fernflower" },
          extendedClientCapabilities = jdtls.extendedClientCapabilities,
          sources = {
            organizeImports = {
              starThreshold = 9999,
              staticStarThreshold = 9999,
            },
          },
          codeGeneration = {
            toString = {
              template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
            },
            useBlocks = true,
          },
        },
        
        flags = {
          allow_incremental_sync = true,
        },
        
        init_options = {
          bundles = {},
        },
      }
      
      -- This starts the LSP server
      jdtls.start_or_attach(config)
      
      -- Java-specific keymaps
      vim.keymap.set("n", "<leader>co", jdtls.organize_imports, { desc = "Organize Imports" })
      vim.keymap.set("n", "<leader>cv", jdtls.extract_variable, { desc = "Extract Variable" })
      vim.keymap.set("n", "<leader>cc", jdtls.extract_constant, { desc = "Extract Constant" })
      vim.keymap.set("v", "<leader>cm", [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]], { desc = "Extract Method" })
      vim.keymap.set("n", "<leader>ct", jdtls.test_nearest_method, { desc = "Test Method" })
      vim.keymap.set("n", "<leader>cT", jdtls.test_class, { desc = "Test Class" })
    end,
  },
}
