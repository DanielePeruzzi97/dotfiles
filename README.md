# dotfiles

Modern development environment configuration for Linux systems with Neovim, Tmux, Zsh, Hyprland, and Ghostty.

## Quick Start

### One-Liner Bootstrap (Fresh Machine)

```bash
curl -fsSL https://raw.githubusercontent.com/DanielePeruzzi97/dotfiles/main/install.sh | bash
```

During migration branch testing:

```bash
DOTFILES_BRANCH=feat/chezmoi-migration \
curl -fsSL "https://raw.githubusercontent.com/DanielePeruzzi97/dotfiles/feat%2Fchezmoi-migration/install.sh" | bash
```

This single command will:
1. Install chezmoi (dotfiles manager)
2. Clone this repository
3. Prompt for your preferences (name, email, work/personal, desktop/server)
4. Install all system packages (via apt/pacman)
5. Install all development tools (via mise)
6. Apply all configurations
7. Set up oh-my-zsh, tmux plugins, fonts, and more

### Manual Installation

If you prefer manual control:

```bash
# Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)"

# Initialize and apply dotfiles
chezmoi init --apply DanielePeruzzi97/dotfiles
```

### After Installation

1. Log out and back in (or `exec zsh`) for shell change to take effect
2. Tmux plugins install automatically; or press `Alt+a` then `I` manually
3. Open nvim - plugins auto-install via lazy.nvim
4. For Hyprland: plugins install automatically when Hyprland is running

## What Gets Installed

### Development Tools (via mise)

All development tools are managed by [mise](https://mise.jdx.dev/) - a single tool that replaces nvm, pyenv, goenv, etc.

Tools installed:
- **Languages:** Go, Node.js
- **Cloud:** AWS CLI, kubectl, k9s, Terraform, Pulumi
- **Utilities:** lazygit, lazydocker, yazi, zoxide, fzf, ripgrep, fd, eza, bat, delta
- **Optional (per config):** talosctl, cilium, hubble, argocd, helm, helmfile

Configuration: `~/.config/mise/config.toml`

### System Packages

Automatically installed based on your distro:
- **Ubuntu/Debian:** via apt
- **Arch/Manjaro/CachyOS:** via pacman + yay (AUR)

Desktop packages (Hyprland, Waybar, Rofi, etc.) only install if you select "desktop" during setup.

## Configuration Structure

```
~/.dotfiles/
├── install.sh                  # Bootstrap script (curl-able)
├── setup.sh                    # Legacy bootstrap entrypoint
├── .chezmoi.toml.tmpl          # User preferences template
├── .chezmoiexternal.toml       # External dependencies (oh-my-zsh, TPM)
├── .chezmoiignore.tmpl         # Conditional file inclusion
├── .chezmoiscripts/            # Automation scripts
│   ├── run_before_00-install-packages.sh.tmpl
│   ├── run_before_10-ensure-mise.sh
│   ├── run_onchange_after_50-mise-install.sh.tmpl
│   ├── run_onchange_after_60-install-fonts.sh
│   ├── run_after_70-change-shell.sh
│   ├── run_onchange_after_71-tmux-plugins.sh.tmpl
│   ├── run_after_80-hyprland-plugins.sh.tmpl
│   ├── run_after_81-systemd-services.sh.tmpl
│   └── run_after_99-private-dotfiles.sh.tmpl
├── dot_config/                 # ~/.config/ files
│   ├── nvim/                   # Neovim configuration
│   ├── ghostty/                # Ghostty terminal
│   ├── alacritty/              # Alacritty terminal
│   ├── mise/                   # Mise tool versions
│   ├── hypr/                   # Hyprland WM
│   ├── waybar/                 # Status bar
│   ├── rofi/                   # App launcher
│   ├── tmux-sessionizer/       # Project navigator
│   ├── k9s/                    # Kubernetes TUI
│   ├── opencode/               # AI assistant
│   └── topgrade/               # System updater
├── dot_local/bin/              # User scripts
├── dot_zshrc                   # Zsh configuration
├── dot_tmux.conf               # Tmux configuration
└── dot_gitconfig.tmpl          # Git config (templated)
```

## Updating Dotfiles

```bash
# Pull latest changes and apply
chezmoi update

# Or manually:
chezmoi git pull
chezmoi apply
```

## Adding New Tools

### Add a mise tool

Edit `~/.dotfiles/dot_config/mise/config.toml`:

```toml
[tools]
newtool = "latest"
```

Then: `chezmoi apply` (triggers mise install automatically)

### Add a system package

Edit `.chezmoiscripts/run_before_00-install-packages.sh.tmpl`

## Platform Notes

### Arch Linux
Clean slate - install scripts add Hyprland and all tools on top of base system.

### Ubuntu Desktop
These dotfiles are **additive** - they install Hyprland alongside your existing desktop environment. At login (GDM), you can choose between GNOME and Hyprland sessions.

## Private Dotfiles (Work)

For work machines, the setup includes integration with a private dotfiles repository containing:
- SSH keys and config
- AWS credentials and profiles
- Work git configuration

The private repo is automatically cloned and applied if:
1. You selected "work machine" during setup
2. Your YubiKey SSH key is available

### Optional: Encrypted Bootstrap Env (YubiKey Touch)

If you want first-run bootstrap to include secrets (for example `GITHUB_TOKEN` for `mise` GitHub API limits),
you can commit an encrypted file that only you can decrypt with YubiKey:

1. Create plaintext env file locally (do **not** commit):

```bash
cat > bootstrap.private.env <<'EOF'
GITHUB_TOKEN=ghp_xxx
EOF
```

2. Encrypt it with your age recipient (YubiKey identity):

```bash
age -r <your-age-recipient> -o bootstrap.private.env.age bootstrap.private.env
rm -f bootstrap.private.env
```

3. Commit only `bootstrap.private.env.age`.

During bootstrap, chezmoi will try to decrypt this file into:
`~/.local/share/dotfiles/bootstrap.private.env` and load it for tool installation.
If decryption fails (no key/token/user), setup continues without breaking public installation.

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

### Neovim
- **Plugin Manager:** lazy.nvim (auto-installs on first run)
- **LSP:** Built-in LSP configuration
- **Autocomplete:** blink.cmp with snippets
- **Theme:** Rose Pine
- **Key Features:** Oil file explorer, Harpoon, Gitsigns, Telescope, Treesitter

### Tmux
- **Prefix:** `Alt+a` (instead of default `Ctrl+b`)
- **Plugin Manager:** TPM (auto-installed)
- **Theme:** Rose Pine inspired
- **Session Manager:** tmux-sessionizer integration

### Zsh
- **Framework:** oh-my-zsh (auto-installed)
- **Theme:** robbyrussell
- **Plugins:** syntax-highlighting, autosuggestions, history-substring-search
- **Key Features:** fzf integration, zoxide, tmux-sessionizer

### Ghostty
- **Theme:** Rose Pine (custom colors)
- **Font:** JetBrainsMono Nerd Font (auto-installed)

## System Updates

System updates are handled by **Topgrade**:

```bash
topgrade  # Update everything
```

## Troubleshooting

### Chezmoi Issues

```bash
# See what would change
chezmoi diff

# Apply with verbose output
chezmoi apply -v

# Re-run setup prompts
chezmoi init --prompt
```

### Neovim Plugins Not Installing

Open nvim and run `:Lazy sync`

### Tmux Plugins Not Installing

In tmux, press: `Alt+a` then `Shift+i`

### Font Icons Not Showing

Ensure JetBrainsMono Nerd Font is installed: `ls ~/.local/share/fonts/JetBrainsMonoNerd*`

If missing: `chezmoi apply` (will re-run font installation)

## Migration from Stow

If you were using the old stow-based setup:

```bash
# Remove old stow symlinks
cd ~/.dotfiles
stow -D nvim tmux zshrc git ghostty hyprland # etc.

# Apply new chezmoi setup
chezmoi init --apply DanielePeruzzi97/dotfiles
```

## License

MIT

## Credits

Configuration inspired by ThePrimeagen, TJ DeVries, and the broader Neovim community.
