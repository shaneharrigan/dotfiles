return {
  {
    "Olical/conjure",
    ft = { "clojure", "clojurescript", "clojurec", "edn" },
    init = function()
      vim.g["conjure#mapping#prefix"] = "<localleader>"
      vim.g["conjure#log#hud#enabled"] = true
      vim.g["conjure#log#botright"] = true
      vim.g["conjure#log#wrap"] = true
      vim.g["conjure#extract#tree_sitter#enabled"] = true
      vim.g["conjure#client#clojure#nrepl#connection#auto_repl#enabled"] = false
      vim.g["conjure#client#clojure#nrepl#eval#auto_require"] = true
    end,
  },

  {
    "PaterJason/cmp-conjure",
    ft = { "clojure", "clojurescript", "clojurec" },
    dependencies = {
      "Olical/conjure",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      local ok, cmp = pcall(require, "cmp")
      if not ok then
        return
      end

      cmp.setup.filetype({ "clojure", "clojurescript", "clojurec" }, {
        sources = cmp.config.sources({
          { name = "conjure", priority = 1200 },
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip", priority = 750 },
          { name = "buffer", priority = 500 },
          { name = "path", priority = 250 },
        }),
      })
    end,
  },

  {
    "guns/vim-sexp",
    ft = { "clojure", "clojurescript", "clojurec", "edn" },
  },

  {
    "tpope/vim-sexp-mappings-for-regular-people",
    ft = { "clojure", "clojurescript", "clojurec", "edn" },
    dependencies = { "guns/vim-sexp" },
  },

  {
    "tpope/vim-repeat",
    event = "VeryLazy",
  },

  {
    "tpope/vim-dispatch",
    cmd = { "Dispatch", "Make", "Start" },
  },

  {
    "radenling/vim-dispatch-neovim",
    dependencies = { "tpope/vim-dispatch" },
  },

  {
    "clojure-vim/vim-jack-in",
    ft = { "clojure", "clojurescript", "clojurec" },
    cmd = { "Clj", "Lein", "Boot" },
    dependencies = {
      "Olical/conjure",
      "tpope/vim-dispatch",
      "radenling/vim-dispatch-neovim",
    },
  },
}
