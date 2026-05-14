return {
  {
    "aklt/plantuml-syntax",
    ft = "plantuml",
    init = function()
      vim.filetype.add({
        extension = {
          iuml = "plantuml",
          plantuml = "plantuml",
          pu = "plantuml",
          puml = "plantuml",
          wsd = "plantuml",
        },
      })
    end,
    config = function()
      local function render(opts)
        local file = vim.api.nvim_buf_get_name(0)
        if file == "" then
          vim.notify("Save this PlantUML buffer before rendering.", vim.log.levels.WARN)
          return
        end

        if vim.fn.executable("plantuml") ~= 1 then
          vim.notify("PlantUML CLI not found. Run ./scripts/install-tools.sh plantuml", vim.log.levels.WARN)
          return
        end

        if vim.bo.modified then
          vim.cmd.write()
        end

        local format = opts.args ~= "" and opts.args or "png"
        vim.system({ "plantuml", "-t" .. format, file }, { text = true }, function(result)
          vim.schedule(function()
            if result.code == 0 then
              vim.notify("PlantUML rendered " .. vim.fn.fnamemodify(file, ":t") .. " as " .. format)
              return
            end

            vim.notify(result.stderr ~= "" and result.stderr or "PlantUML render failed.", vim.log.levels.ERROR)
          end)
        end)
      end

      vim.api.nvim_create_user_command("PlantumlRender", render, {
        nargs = "?",
        complete = function()
          return { "png", "svg", "pdf", "txt", "utxt" }
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "plantuml",
        callback = function(args)
          vim.bo[args.buf].commentstring = "' %s"
          vim.keymap.set("n", "<leader>pr", "<cmd>PlantumlRender<cr>", {
            buffer = args.buf,
            desc = "Render PlantUML",
          })
          vim.keymap.set("n", "<leader>ps", "<cmd>PlantumlRender svg<cr>", {
            buffer = args.buf,
            desc = "Render PlantUML as SVG",
          })
        end,
      })
    end,
  },
}
