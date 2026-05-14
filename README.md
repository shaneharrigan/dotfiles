# Dotfiles

Personal dotfiles managed with GNU Stow. Each top-level package mirrors the
paths that should appear under `$HOME`, so stowing `nvim` links
`nvim/.config/nvim` to `~/.config/nvim`, stowing `tmux` links `.tmux.conf`, and
so on.

## Packages

Core packages:

- `nvim`: Neovim configuration.
- `tmux`: tmux configuration.
- `zsh`: zsh configuration.

Optional overlays:

- `nvim-delight`: extra Neovim UI/dashboard polish.
- `tmux-delight`: extra tmux flow configuration.
- `zsh-flow`: additional zsh flow helpers.
- `zsh-omz-delight`: Oh My Zsh customizations.

## First Run

From the repo root:

```bash
./scripts/bootstrap.sh
```

This installs common CLI tools with Homebrew or `apt`, ensures `stow` is
available, and stows the default packages:

```text
nvim tmux zsh
```

Reload your shell after bootstrapping:

```bash
exec zsh
```

## Stow Usage

Preview what would be linked before changing anything:

```bash
./scripts/stow-dotfiles.sh --dry-run
```

Stow the default packages:

```bash
./scripts/stow-dotfiles.sh
```

Stow specific packages:

```bash
./scripts/stow-dotfiles.sh zsh tmux
./scripts/stow-dotfiles.sh nvim nvim-delight
./scripts/stow-dotfiles.sh zsh zsh-flow zsh-omz-delight
```

Use a custom target directory:

```bash
./scripts/stow-dotfiles.sh --target "$HOME" nvim
```

Unstow a package manually with GNU Stow:

```bash
stow -d "$PWD" -t "$HOME" -D nvim
```

Restow a package after moving files around:

```bash
stow -d "$PWD" -t "$HOME" -R nvim
```

If Stow reports a conflict, move or remove the existing real file first. Stow
will not overwrite normal files with symlinks.

## Tool Installer

Install the default supporting tools:

```bash
./scripts/install-tools.sh
```

Install selected tools only:

```bash
./scripts/install-tools.sh ripgrep fzf zoxide stow
```

Supported tool names are documented by:

```bash
./scripts/install-tools.sh --help
```

## Neovim

The Neovim config uses `lazy.nvim`, Mason, LSP, Treesitter, completion, snippets,
formatters, linters, DAP, and test integration.

Language support includes Java, Clojure, Go, Rust, C/C++, Python, Bash/Zsh,
Docker/Docker Compose, JavaScript/TypeScript, HTML/CSS, Lua, JSON, YAML,
Markdown, TOML, Vimscript, and SQL syntax.

Java quality checks use `jdtls` diagnostics plus `checkstyle` by default. If you
install PMD, Neovim will also run PMD for Java buffers:

```bash
./scripts/install-tools.sh pmd spotbugs
```

`spotbugs` is installed as a project/build tool rather than an on-save editor
linter because it analyzes compiled Java bytecode.

The LSP servers can provide snippet-style completions when a language server
supports them. `nvim-cmp` and `LuaSnip` are already configured to expand those
snippets, and `friendly-snippets` adds a broad set of editor-side snippets for
common languages. This means you get two useful sources:

- LSP snippets from servers such as `ts_ls`, `html`, `cssls`, `gopls`,
  `rust_analyzer`, `lua_ls`, and others when they advertise snippet completions.
- Static snippets from `friendly-snippets` through `LuaSnip`.

After opening Neovim for the first time, run:

```vim
:Lazy
:Mason
```

Use those screens to confirm plugins and language tools installed correctly.

## Useful Scripts

- `scripts/bootstrap.sh`: install tools and stow packages.
- `scripts/stow-dotfiles.sh`: stow selected packages into a target directory.
- `scripts/install-tools.sh`: install common CLI dependencies.
- `scripts/tmux-sessionizer.sh`: tmux session picker helper.
- `scripts/tmux-path-display.sh`: tmux path display helper.
- `scripts/workflow-health.sh`: local workflow health checks.

## Updating

Pull the latest changes, then restow packages if paths changed:

```bash
git pull
stow -d "$PWD" -t "$HOME" -R nvim tmux zsh
```

For Neovim plugin updates, use `:Lazy` inside Neovim.
