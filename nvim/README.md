# Neovim IDE Configuration for Go & Java

A powerful, feature-rich Neovim configuration optimized for Go and Java development, with comprehensive LSP support, debugging, testing, and modern IDE features.

## 🚀 Features

### Core Features
- **Language Support**: Full LSP support for Go, Java, and Lua
- **Debugging**: DAP (Debug Adapter Protocol) with UI for Go and Java
- **Testing**: Integrated test runners with neotest
- **Auto-completion**: Intelligent code completion with snippets
- **Syntax Highlighting**: Treesitter-based syntax highlighting
- **Formatting & Linting**: Auto-format on save with conform.nvim and nvim-lint
- **Git Integration**: Gitsigns, LazyGit, and Telescope git commands
- **Fuzzy Finding**: Telescope with FZF native extension
- **File Explorer**: nvim-tree with git integration
- **Which-Key**: Interactive keybinding helper

### Go-Specific Features
- gopls with full configuration (inlay hints, codelenses, etc.)
- Auto-import and formatting with goimports/gofumpt
- Struct tag management
- Interface implementation generation
- Error handling code generation
- Go test integration with debugging support
- Delve debugger integration

### Java-Specific Features
- Eclipse JDT Language Server (jdtls)
- Maven & Gradle support
- Code generation (toString, getters/setters, etc.)
- Organize imports
- Extract variable/constant/method refactoring
- JUnit test integration
- Java debug adapter

## 📦 Installation

### Prerequisites

1. **Neovim >= 0.9.0**
   ```bash
   brew install neovim
   ```

2. **Required system dependencies**
   ```bash
   # macOS
   brew install git ripgrep fd lazygit
   brew install node  # for some LSP servers
   brew install go    # for Go development
   brew install openjdk@17  # for Java development
   ```

3. **Optional but recommended**
   ```bash
   brew install fzf  # Better fuzzy finding
   ```

### Setup

Your configuration is already in place at `~/.config/nvim`. To activate it:

1. Open Neovim:
   ```bash
   nvim
   ```

2. Lazy.nvim will automatically install all plugins on first launch

3. Mason will auto-install language servers and tools

4. Wait for all installations to complete (check with `:Lazy` and `:Mason`)

## ⌨️ Keybindings

Leader key: `<Space>`

### General

| Key | Description |
|-----|-------------|
| `<leader>w` | Save file |
| `<leader>qq` | Quit all |
| `<leader>bd` | Delete buffer |
| `<S-h>` | Previous buffer |
| `<S-l>` | Next buffer |
| `<Esc>` | Clear search highlight |
| `jk` | Exit insert mode |
| `<C-d>` / `<C-u>` | Scroll down/up (centered) |
| `<C-h/j/k/l>` | Navigate windows |

### File Explorer (nvim-tree)

| Key | Description |
|-----|-------------|
| `<leader>e` | Toggle file explorer |
| `<leader>E` | Focus file explorer |

### Telescope (Fuzzy Finder)

| Key | Description |
|-----|-------------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep (search text) |
| `<leader>fb` | Find buffers |
| `<leader>fh` | Help tags |
| `<leader>fr` | Recent files |
| `<leader>fs` | Document symbols |
| `<leader>fS` | Workspace symbols |

### LSP

| Key | Description |
|-----|-------------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | References |
| `gi` | Go to implementation |
| `gt` | Type definition |
| `K` | Hover documentation |
| `<C-k>` | Signature help |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code actions (with preview) |
| `<leader>f` | Format buffer |
| `[d` / `]d` | Previous/next diagnostic |
| `<leader>d` | Show line diagnostics |

### Debugging (DAP)

| Key | Description |
|-----|-------------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dc` | Continue |
| `<leader>dC` | Run to cursor |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>dr` | Toggle REPL |
| `<leader>dt` | Toggle DAP UI |
| `<leader>dx` | Terminate |
| `<leader>dh` | Hover (debug) |

### Testing (Neotest)

| Key | Description |
|-----|-------------|
| `<leader>tt` | Test nearest |
| `<leader>tf` | Test file |
| `<leader>ts` | Toggle test summary |
| `<leader>to` | Test output |
| `<leader>tO` | Test output panel |
| `<leader>tS` | Stop test |

### Git

| Key | Description |
|-----|-------------|
| `<leader>gg` | LazyGit |
| `<leader>gb` | Git branches |
| `<leader>gc` | Git commits |
| `<leader>gs` | Git status |
| `]c` / `[c` | Next/previous hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hp` | Preview hunk |
| `<leader>hb` | Blame line |

### Go-Specific

| Key | Description |
|-----|-------------|
| `<leader>gf` | Fill struct |
| `<leader>ge` | Generate if err |
| `<leader>gt` | Add struct tags |
| `<leader>gT` | Remove struct tags |
| `<leader>gi` | Implement interface |
| `<leader>gm` | Go mod tidy |

### Java-Specific

| Key | Description |
|-----|-------------|
| `<leader>co` | Organize imports |
| `<leader>cv` | Extract variable |
| `<leader>cc` | Extract constant |
| `<leader>cm` | Extract method (visual mode) |
| `<leader>ct` | Test method |
| `<leader>cT` | Test class |

### Trouble (Diagnostics)

| Key | Description |
|-----|-------------|
| `<leader>xx` | Toggle diagnostics |
| `<leader>xX` | Buffer diagnostics |
| `<leader>xl` | Location list |
| `<leader>xq` | Quickfix list |

### Treesitter Text Objects

| Key | Description |
|-----|-------------|
| `af` / `if` | Around/inside function |
| `ac` / `ic` | Around/inside class |
| `aa` / `ia` | Around/inside parameter |
| `]m` / `[m` | Next/previous function start |
| `]]` / `[[` | Next/previous class start |

## 📁 Structure

```
~/.config/nvim/
├── init.lua                    # Main configuration
├── lua/
│   ├── config/
│   │   └── keymaps.lua        # Global keymaps
│   └── plugins/
│       ├── dap.lua            # Debug Adapter Protocol
│       ├── go.lua             # Go-specific enhancements
│       ├── ide.lua            # IDE features (telescope, tree, etc.)
│       ├── java.lua           # Java LSP (jdtls)
│       ├── lsp.lua            # Completion (nvim-cmp)
│       ├── mason.lua          # LSP/tool installer
│       ├── nvm-lspconfig.lua  # LSP configuration
│       ├── theme.lua          # Color themes
│       └── treesitter.lua     # Syntax highlighting
└── lazy-lock.json             # Plugin version lock
```

## 🔧 Configuration

### Language Servers

Automatically installed via Mason:
- **gopls**: Go
- **jdtls**: Java
- **lua_ls**: Lua

### Formatters

- Go: `gofumpt`, `goimports`
- Java: `google-java-format`
- Lua: `stylua`
- JSON/YAML/Markdown: `prettier`

### Linters

- Go: `golangci-lint`
- Java: `checkstyle`

### Debuggers

- Go: `delve`
- Java: `java-debug-adapter`, `java-test`

## 🎨 Theme

Default: Tokyo Night (night variant)

To switch themes, edit [lua/plugins/theme.lua](lua/plugins/theme.lua) and set `enabled` accordingly.

## 📝 Customization

### Adding a New Language

1. Add the LSP server to [lua/plugins/mason.lua](lua/plugins/mason.lua):
   ```lua
   ensure_installed = {
     "your-lsp-server",
     -- ...
   }
   ```

2. Configure the LSP in [lua/plugins/nvm-lspconfig.lua](lua/plugins/nvm-lspconfig.lua):
   ```lua
   lspconfig.your_lsp.setup({
     capabilities = capabilities,
   })
   ```

3. Add formatter/linter in [lua/plugins/ide.lua](lua/plugins/ide.lua)

### Modifying Keymaps

Edit [lua/config/keymaps.lua](lua/config/keymaps.lua) for global keymaps, or the specific plugin file for plugin-specific mappings.

## 🐛 Troubleshooting

### LSP not working

1. Check if the language server is installed:
   ```vim
   :Mason
   ```

2. Check LSP status:
   ```vim
   :LspInfo
   ```

3. Check logs:
   ```vim
   :lua vim.cmd('e ' .. vim.lsp.get_log_path())
   ```

### Java LSP not starting

1. Ensure Java 17+ is installed:
   ```bash
   java --version
   ```

2. Check jdtls workspace:
   ```bash
   ls ~/.local/share/nvim/jdtls-workspace/
   ```

### Go tools not working

1. Ensure Go is installed:
   ```bash
   go version
   ```

2. Install Go tools manually if needed:
   ```vim
   :GoInstallBinaries
   ```

## 🚀 Next Steps

1. **Learn the keybindings**: Press `<Space>` to see available commands via which-key
2. **Customize to your needs**: Edit the configuration files
3. **Add more plugins**: Check out [awesome-neovim](https://github.com/rockerBOO/awesome-neovim)
4. **Join the community**: [r/neovim](https://reddit.com/r/neovim)

## 📚 Resources

- [Neovim Documentation](https://neovim.io/doc/)
- [Lazy.nvim](https://github.com/folke/lazy.nvim)
- [Mason.nvim](https://github.com/williamboman/mason.nvim)
- [LSP Config](https://github.com/neovim/nvim-lspconfig)
- [Telescope](https://github.com/nvim-telescope/telescope.nvim)

## 🙏 Credits

This configuration uses many amazing plugins from the Neovim community. Special thanks to all plugin authors!
