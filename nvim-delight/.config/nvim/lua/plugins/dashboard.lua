return {
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        "",
        "  ███╗   ██╗██╗   ██╗██╗███╗   ███╗",
        "  ████╗  ██║██║   ██║██║████╗ ████║",
        "  ██╔██╗ ██║██║   ██║██║██╔████╔██║",
        "  ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
        "  ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
        "  ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
        "",
      }

      dashboard.section.buttons.val = {
        dashboard.button("f", "Find file", "<cmd>Telescope find_files<cr>"),
        dashboard.button("r", "Recent files", "<cmd>Telescope oldfiles<cr>"),
        dashboard.button("g", "Live grep", "<cmd>Telescope live_grep<cr>"),
        dashboard.button("n", "New file", "<cmd>enew<cr>"),
        dashboard.button("l", "Lazy plugins", "<cmd>Lazy<cr>"),
        dashboard.button("q", "Quit", "<cmd>qa<cr>"),
      }

      dashboard.section.footer.val = {
        "",
        "Flow state: online.",
      }

      dashboard.opts.opts.noautocmd = true
      alpha.setup(dashboard.opts)
    end,
  },
}
