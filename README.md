# dotfiles

Modern development environment configuration for Linux systems with Neovim, Tmux, Zsh, Hyprland, and Ghostty.

## Quick Start

```bash
git clone https://github.com/YOUR_USERNAME/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install/all.sh
```

### Installation Options

```bash
./install/all.sh              # Full installation
./install/all.sh --minimal    # Terminal only (no desktop/k8s/flatpak)
./install/all.sh --no-desktop # Skip desktop apps
./install/all.sh --no-k8s     # Skip Kubernetes tools
./install/all.sh --no-flatpak # Skip Flatpak apps
```

### After Installation

1. Log out and back in (or `exec zsh`)
2. In tmux: `Alt+a` then `I` to install plugins
3. Open nvim - plugins auto-install
4. For Hyprland: `hyprpm reload`

## Platform Notes

### Arch Linux
Clean slate - install scripts add Hyprland and all tools on top of base system.

### Ubuntu Desktop
These dotfiles are **additive** - they install Hyprland alongside your existing desktop environment. At login (GDM), you can choose between GNOME and Hyprland sessions.

**If you want a minimal Ubuntu setup** (stripped GNOME, Hyprland-only):
- This is a manual, one-time operation outside these dotfiles
- Not automated because it's destructive and hard to reverse
- The install scripts work the same regardless of whether GNOME is present

The goal is identical Hyprland experience on both distros, with different bases underneath. This is intentional - Ubuntu's GNOME remnants don't affect Hyprland usage.

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

# Core terminal tools
stow -t ~ nvim tmux zshrc git ghostty

# Desktop environment (Hyprland)
stow -t ~ hyprland

# Additional tools
stow -t ~ topgrade k9s
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
├── install/                 # Modular installation scripts
│   ├── all.sh               # Master orchestrator
│   ├── helpers/             # Shared utilities (logging, detect, packages)
│   ├── packages/            # Package installation (base, neovim, hyprland, k8s)
│   ├── config/              # Tool setup (shell, tmux, fonts, nvm, go)
│   ├── services/            # Systemd services
│   ├── stow/                # Backup and stow application
│   └── post-install/        # Final setup (shell change, plugins)
├── alacritty/               # Alacritty terminal config
├── bin/                     # User scripts (~/.local/bin)
├── ghostty/                 # Ghostty terminal config
├── git/                     # Git configuration
├── hyprland/                # Hyprland WM + Waybar + Rofi
├── k9s/                     # Kubernetes TUI config
├── nvim/                    # Neovim configuration
├── opencode/                # OpenCode AI assistant config
├── scripts/                 # Misc utility scripts
├── tmux/                    # Tmux configuration
├── topgrade/                # Universal updater config
├── zen/                     # Zen browser config
└── zshrc/                   # Zsh configuration
```

## Keyboard-Centric Workflow

This dotfile configuration implements a **unified keyboard-centric workflow** across Zsh, Tmux, and Neovim with consistent keybindings for maximum muscle memory retention.

### Core Principles
- **hjkl navigation** everywhere (vim-style)
- **Alt+hjkl** for window/pane resizing
- **Ctrl+hjkl** for seamless pane switching (Neovim ↔ Tmux)
- **Alt+1/2/3** for quick session access
- **Ctrl+d/u** for half-page scrolling with centering
- **No vi-mode in Zsh** - uses intuitive emacs mode with vim-style enhancements

### Quick Reference
- Full reference: `cat ~/.dotfiles/KEYBINDINGS.md`
- Quick card: `cat ~/.dotfiles/KEYBINDINGS-QUICK-REF.txt`

### Highlights
- **Tmux Copy Mode**: Enhanced vi-style selection with `v` (visual), `V` (line), `Ctrl+v` (rectangle)
- **Clipboard Integration**: Seamless copy/paste with `xclip` (X11) and `wl-clipboard` (Wayland)
- **Centered Scrolling**: `Ctrl+d/u` always centers your cursor
- **Search & Yank**: `/` to search, `n/N` to navigate, `y` to copy in tmux copy mode
- **Consistent Navigation**: Same muscle memory across terminal, tmux, and vim

## Key Features

### Hyprland (Wayland Desktop)
- **Window Manager:** Hyprland with hyprsplit plugin (per-monitor workspaces)
- **Bar:** Waybar with system info, workspaces, updates indicator
- **Launcher:** Rofi (drun, window switcher, clipboard history)
- **Notifications:** SwayNC (notification center + power menu)
- **Lock Screen:** Hyprlock
- **Theme:** Rose Pine inspired

**Essential Keybindings:**

| Key | Action |
|-----|--------|
| `Super+T` | Open terminal (Ghostty) |
| `Super+Q` | Close window |
| `Super+S` | App launcher (Rofi) |
| `Super+B` | Open browser (Zen) |
| `Super+E` | File manager |
| `Super+M` | Fullscreen |
| `Super+V` | Toggle floating |
| `Super+Escape` | Lock screen |
| `Super+Shift+Q` | Notification center / Power menu |

**Window Navigation:**

| Key | Action |
|-----|--------|
| `Super+HJKL` | Move focus |
| `Super+Shift+HJKL` | Move window |
| `Super+Ctrl+HJKL` | Resize window |
| `Super+Tab` | Focus next monitor |
| `Super+Shift+Tab` | Move window to next monitor |

**Workspaces (per-monitor via hyprsplit):**

| Key | Action |
|-----|--------|
| `Super+1-5` | Switch to workspace |
| `Super+Shift+1-5` | Move window to workspace |
| `Super+Shift+O` | Move workspace to next monitor |

**Other:**

| Key | Action |
|-----|--------|
| `Super+Space` | Toggle keyboard layout (us/it) |
| `Super+=/−` | Zoom in/out |
| `Super+Shift+0` | Reset zoom |
| `Print` | Screenshot (full screen) |
| `Shift+Print` | Screenshot (area select) |
| `Super+Shift+V` | Clipboard history |

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
- **Enhanced Copy Mode:** Vi-style with visual selection, rectangle selection, and clipboard integration
- **Key Bindings:**
  - `Alt+a` + `f` - Fuzzy project finder
  - `Alt+a` + `v` - Split horizontally
  - `Alt+a` + `h` - Split vertically
  - `Alt+a` + `[` - Enter copy mode
  - `Ctrl+h/j/k/l` - Navigate panes (vim-style, seamless with nvim)
  - `Alt+hjkl` - Resize panes
  - **Copy Mode:** `v` visual, `V` line, `Ctrl+v` rectangle, `y` yank, `/` search

### Zsh
- **Framework:** oh-my-zsh
- **Theme:** robbyrussell
- **Mode:** Emacs mode (NO vi-mode) with vim-style navigation enhancements
- **Key Features:**
  - Syntax highlighting
  - Auto-suggestions
  - Substring history search
  - fzf integration
  - zoxide (smart cd)
  - tmux-sessionizer integration
- **Key Bindings:**
  - `Ctrl+f` - Fuzzy project finder
  - `Alt+hjkl` - Vim-style cursor movement
  - `Ctrl+p` - Accept auto-suggestion
  - `Ctrl+r` - Fuzzy history search

### Ghostty
- **Theme:** Rose Pine (custom colors)
- **Font:** JetBrainsMono Nerd Font, size 17
- **Features:**
  - Shell integration (sudo, title detection)
  - No window decorations (native Wayland)
  - Block cursor with low opacity
  - Mouse hide while typing
  - GTK single instance mode

### Alacritty (Legacy)
- **Theme:** Rose Pine
- **Font:** Configured for Nerd Fonts
- **Note:** Ghostty is the primary terminal; Alacritty config kept for compatibility

## System Updates

System updates are handled by **Topgrade**, a universal updater that refreshes everything in one command.

### Running Updates

```bash
# Update everything
topgrade

# Update specific components only
topgrade --only system  # OS packages only
topgrade --only cargo   # Rust packages only
```

### What Gets Updated

Topgrade automatically detects and updates:
- **System packages** (apt/pacman/dnf depending on distro)
- **AUR packages** (via yay on Arch)
- **Homebrew** packages and casks
- **Cargo** (Rust) packages
- **npm** global packages
- **Flatpak** applications
- **Firmware** (via fwupd)
- **oh-my-zsh** plugins
- **Tmux** plugins (via TPM)
- **Neovim** plugins (via lazy.nvim)

### Waybar Integration

The waybar shows available updates and clicking it runs topgrade. After updates complete, waybar refreshes automatically.

### Configuration

Topgrade config: `~/.config/topgrade/topgrade.toml`

Key settings:
- `assume_yes = true` - No confirmation prompts
- `cleanup = true` - Auto-cleanup after updates
- Custom commands for oh-my-zsh and tmux plugin updates

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
