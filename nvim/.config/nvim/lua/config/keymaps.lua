------------------------------------------------------------------
-- General Keymaps
------------------------------------------------------------------

-- Better escape
vim.keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode" })

-- Save file
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })

-- Skip 10 lines at a time
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up" })

-- Keep search results centered
vim.keymap.set("n", "n", "nzzzv", { desc = "Next result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev result" })

-- Better indenting
vim.keymap.set("v", "<", "<gv", { desc = "Indent left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right" })

-- Move selected lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Better paste
vim.keymap.set("v", "p", '"_dP', { desc = "Paste without yanking" })

-- Clear search highlighting
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear highlights" })

-- Show full diagnostics in a focusable floating window
vim.keymap.set("n", "<leader>ll", function()
  vim.diagnostic.open_float(nil, {
    scope = "line",
    focusable = true,
    border = "rounded",
    source = "always",
    max_width = 140,
  })
end, { desc = "Line diagnostics (full)" })

local function ex_single_quoted_literal(text)
  return text:gsub("\\", "\\\\"):gsub("'", "''")
end

local function ex_replacement_literal(text)
  return text:gsub("\\", "\\\\"):gsub("&", "\\&")
end

-- Replace current visual selection throughout the whole buffer
vim.keymap.set("x", "<leader>sr", function()
  local esc = vim.fn.escape(vim.fn.getreg(""), "\\/.*$^~[]")
  local cmd = string.format(":%%s/%s//gc<Left><Left><Left>", esc)
  local keys = vim.api.nvim_replace_termcodes(cmd, true, false, true)
  vim.fn.feedkeys(keys, "n")
end, { desc = "Substitute selection in buffer" })

-- Prompted substitute in current buffer (literal find text)
vim.keymap.set("n", "<leader>sa", function()
  local find = vim.fn.input("Find (literal): ")
  if find == "" then
    return
  end
  local replace = vim.fn.input("Replace with: ")
  local confirm = vim.fn.input("Confirm each? [y/N]: ")
  local flags = "g"
  if confirm:lower() == "y" then
    flags = "gc"
  end

  vim.cmd(string.format(
    "%%s/\\V%s/%s/%s",
    ex_single_quoted_literal(find),
    ex_replacement_literal(replace),
    flags
  ))
end, { desc = "Substitute in buffer (prompt)" })

-- Prompted substitute only inside double quotes
vim.keymap.set("n", "<leader>su", function()
  local find = vim.fn.input("Inside quotes, replace (literal): ")
  if find == "" then
    return
  end
  local replace = vim.fn.input("With: ")

  vim.cmd(string.format(
    "%%s/\"\\zs[^\"]*\\ze\"/\\=substitute(submatch(0), '\\\\V%s', '%s', 'g')/g",
    ex_single_quoted_literal(find),
    ex_replacement_literal(replace)
  ))
end, { desc = "Substitute in quotes (prompt)" })

-- Prompted word-under-cursor replace (whole word, buffer-wide)
vim.keymap.set("n", "<leader>sw", function()
  local word = vim.fn.expand("<cword>")
  if word == "" then
    return
  end
  local replace = vim.fn.input("Replace '" .. word .. "' with: ")
  vim.cmd(string.format(
    "%%s/\\<%s\\>/%s/gc",
    vim.fn.escape(word, [[\\/]]),
    ex_replacement_literal(replace)
  ))
end, { desc = "Replace word under cursor" })

-- Remove trailing whitespace in the whole buffer and keep cursor position
vim.keymap.set("n", "<leader>st", function()
  local cursor = vim.api.nvim_win_get_cursor(0)
  vim.cmd([[%s/\s\+$//e]])
  vim.api.nvim_win_set_cursor(0, cursor)
end, { desc = "Trim trailing whitespace" })

-- Hover docs (prevent fallback to :Man when LSP is not attached)
vim.keymap.set("n", "K", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  if clients and #clients > 0 then
    vim.lsp.buf.hover()
    return
  end

  local ft = vim.bo[bufnr].filetype
  local candidates_by_ft = {
    javascript = { "ts_ls", "tsserver" },
    javascriptreact = { "ts_ls", "tsserver" },
    typescript = { "ts_ls", "tsserver" },
    typescriptreact = { "ts_ls", "tsserver" },
    html = { "html" },
    python = { "pyright" },
    go = { "gopls" },
    lua = { "lua_ls" },
    c = { "clangd" },
    cpp = { "clangd" },
  }

  local candidates = candidates_by_ft[ft] or {}
  for _, server in ipairs(candidates) do
    pcall(vim.cmd, "silent! LspStart " .. server)
  end

  vim.defer_fn(function()
    local retry_clients = vim.lsp.get_clients({ bufnr = bufnr })
    if retry_clients and #retry_clients > 0 then
      vim.lsp.buf.hover()
    else
      vim.notify("No LSP hover available for this buffer", vim.log.levels.WARN)
    end
  end, 250)
end, { desc = "Hover Documentation" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Window resizing
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Buffer navigation
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

-- Quit
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

------------------------------------------------------------------
-- Plugin-specific Keymaps
------------------------------------------------------------------

-- File explorer (nvim-tree)
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Explorer" })
vim.keymap.set("n", "<leader>E", "<cmd>NvimTreeFocus<cr>", { desc = "Focus Explorer" })

-- Telescope
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live Grep" })
vim.keymap.set("n", "<leader>fd", function()
  require("telescope.builtin").live_grep({
    search_dirs = { vim.fn.expand("%:p:h") },
    prompt_title = "Grep in " .. vim.fn.fnamemodify(vim.fn.expand("%:p:h"), ":~:.")
  })
end, { desc = "Grep in Current Dir" })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help Tags" })
vim.keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Recent Files" })
vim.keymap.set("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "Document Symbols" })
vim.keymap.set("n", "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<cr>", { desc = "Workspace Symbols" })

-- Git
vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
vim.keymap.set("n", "<leader>gb", "<cmd>Telescope git_branches<cr>", { desc = "Git Branches" })
vim.keymap.set("n", "<leader>gc", "<cmd>Telescope git_commits<cr>", { desc = "Git Commits" })
vim.keymap.set("n", "<leader>gs", "<cmd>Telescope git_status<cr>", { desc = "Git Status" })


