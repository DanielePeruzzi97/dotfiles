# dotfiles

Modern development environment configuration for Linux systems with Neovim, Tmux, Zsh, and Alacritty.

## Quick Start (Fresh Installation)

For a fresh Linux installation, run the automated setup:

```bash
git clone https://github.com/YOUR_USERNAME/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
chmod +x install.sh
./install.sh
```

The installation script will:
- ✅ Detect your Linux distribution (Ubuntu/Debian, Fedora/RHEL, Arch)
- ✅ Install all system packages (zsh, tmux, neovim, fzf, ripgrep, etc.)
- ✅ Install Homebrew for Linux
- ✅ Install development tools (lazygit, yazi, zoxide, nvm, Go)
- ✅ Setup oh-my-zsh with plugins
- ✅ Install JetBrainsMono Nerd Font
- ✅ Install TPM (Tmux Plugin Manager)
- ✅ Backup existing configurations
- ✅ Stow all dotfiles to your home directory

After installation completes:
1. Log out and log back in (or run `exec zsh`)
2. Open tmux and press `Alt+a` then `I` to install tmux plugins
3. Open nvim - plugins will auto-install via lazy.nvim
4. Configure your terminal to use JetBrainsMono Nerd Font

## Manual Installation

If you prefer manual control or the automated script doesn't support your distribution:

### Prerequisites

Install these packages using your distribution's package manager:

- **Shell & Terminal:**
  - zsh + oh-my-zsh
  - Alacritty
  - Tmux
  
- **Core Tools:**
  - git
  - stow
  - curl/wget
  - xclip (clipboard support)
  
- **Search & Navigation:**
  - fzf (fuzzy finder)
  - fd-find (better find)
  - ripgrep (better grep)
  
- **Development:**
  - neovim (>= 0.9.0)
  - A Nerd Font (e.g., JetBrainsMono)
  - lazygit (git UI)
  - yazi (file manager)
  - zoxide (smart cd)

### Zsh Plugins

Install these oh-my-zsh custom plugins:

```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

git clone https://github.com/zsh-users/zsh-autosuggestions.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-history-substring-search.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
```

### Tmux Plugin Manager

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

After installing, press `prefix` + `I` in tmux to install plugins (prefix = `Alt+a`).

### Apply Dotfiles

Clone this repository and use stow:

```bash
git clone https://github.com/YOUR_USERNAME/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow -t ~ nvim tmux zshrc alacritty git
```

## Utility Script

The `dotfiles.sh` script provides convenient commands:

### Copy to System Path

```bash
sudo cp dotfiles.sh /usr/local/bin/dotfiles
sudo chmod +x /usr/local/bin/dotfiles
```

### Usage

```bash
# Full system installation (fresh setup)
dotfiles install

# Sync all dotfiles
dotfiles sync all

# Sync specific packages
dotfiles sync nvim tmux zshrc

# Sync single package
dotfiles sync nvim
```

## Configuration Structure

```
~/.dotfiles/
├── alacritty/     # Terminal emulator config
├── git/           # Git configuration
├── nvim/          # Neovim configuration
├── tmux/          # Tmux configuration
├── zshrc/         # Zsh configuration
├── install.sh     # Automated installation script
├── dotfiles.sh    # Utility script
└── README.md      # This file
```

## Key Features

### Neovim
- **Plugin Manager:** lazy.nvim (auto-installs on first run)
- **LSP:** Built-in LSP configuration
- **Autocomplete:** blink.cmp with snippets
- **Theme:** Rose Pine
- **Key Features:** Oil file explorer, Harpoon, Gitsigns, Telescope, Treesitter

### Tmux
- **Prefix:** `Alt+a` (instead of default `Ctrl+b`)
- **Plugin Manager:** TPM
- **Theme:** Rose Pine inspired
- **Session Manager:** tmux-sessionizer integration
- **Key Bindings:**
  - `Alt+a` + `f` - Fuzzy project finder
  - `Alt+a` + `v` - Split horizontally
  - `Alt+a` + `h` - Split vertically
  - `Alt+g` - Quick lazygit popup
  - `Ctrl+h/j/k/l` - Navigate panes (vim-style)

### Zsh
- **Framework:** oh-my-zsh
- **Theme:** robbyrussell
- **Key Features:**
  - Syntax highlighting
  - Auto-suggestions
  - Substring history search
  - fzf integration
  - zoxide (smart cd)
  - tmux-sessionizer integration
- **Key Bindings:**
  - `Ctrl+f` - Fuzzy project finder
  - `Alt+g` - Quick lazygit
  - `Ctrl+p` - Accept auto-suggestion

### Alacritty
- **Theme:** Rose Pine
- **Font:** Configured for Nerd Fonts

## Customization

### Add Private/Local Configurations

Create a `~/.credentials.sh` file for private environment variables and credentials. It will be automatically sourced by zsh.

### Modify Packages

Each directory in `~/.dotfiles/` represents a stow package. To add new configurations:

1. Create a directory (e.g., `myapp/`)
2. Mirror the home directory structure inside it
3. Add your config files
4. Run `dotfiles sync myapp`

## Plugins to Explore

### NVIM
- kevinhwang91/nvim-bqf - Better quickfix
- gpanders/nvim-parinfer - Lisp editing
- glacambre/firenvim - Neovim in browser
- nvim-tree - File explorer alternative
- kndndrj/nvim-dbee - Database interface

## Troubleshooting

### Stow Conflicts

If stow reports conflicts, either:
1. Remove/backup the conflicting files manually
2. Let the install script backup them automatically

### Neovim Plugins Not Installing

Open nvim and run:
```vim
:Lazy sync
```

### Tmux Plugins Not Installing

In tmux, press: `Alt+a` then `Shift+i`

### Font Icons Not Showing

Ensure your terminal emulator is configured to use a Nerd Font (e.g., JetBrainsMono Nerd Font).

## License

MIT

## Credits

Configuration inspired by ThePrimeagen, TJ DeVries, and the broader Neovim community.
