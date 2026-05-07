vim.opt_local.lisp = true
vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.expandtab = true
vim.opt_local.commentstring = ";; %s"
vim.opt_local.formatoptions:remove({ "t" })

vim.opt_local.lispwords:append({
  "as->",
  "binding",
  "comment",
  "cond->",
  "cond->>",
  "def",
  "defmethod",
  "defmulti",
  "defn",
  "defn-",
  "defonce",
  "defprotocol",
  "defrecord",
  "deftest",
  "doseq",
  "fn",
  "go",
  "go-loop",
  "if-let",
  "let",
  "letfn",
  "reify",
  "testing",
  "try",
  "when-first",
  "when-let",
})

local opts = { buffer = true, silent = true }
local function map(mode, lhs, rhs, desc)
  opts.desc = desc
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<localleader>cc", "<cmd>ConjureConnect<cr>", "Conjure connect")
map("n", "<localleader>cs", "<cmd>ConjureShadowSelect<cr>", "Select shadow-cljs build")
map("n", "<localleader>cl", "<cmd>ConjureLogVSplit<cr>", "Conjure log")
map("n", "<localleader>cq", "<cmd>ConjureLogCloseVisible<cr>", "Conjure close log")
map("n", "<localleader>ee", "<cmd>ConjureEvalCurrentForm<cr>", "Eval form")
map("n", "<localleader>er", "<cmd>ConjureEvalRootForm<cr>", "Eval root form")
map("n", "<localleader>eb", "<cmd>ConjureEvalBuf<cr>", "Eval buffer")
map("v", "<localleader>e", "<cmd>ConjureEvalVisual<cr>", "Eval selection")
map("n", "<localleader>lf", function()
  vim.lsp.buf.format({ async = true })
end, "Format Clojure buffer")
map("n", "<localleader>la", vim.lsp.buf.code_action, "Clojure code action")
map("n", "<localleader>lr", vim.lsp.buf.rename, "Rename symbol")
