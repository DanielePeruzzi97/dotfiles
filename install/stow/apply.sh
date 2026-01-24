#!/usr/bin/env bash
set -e

DOTFILES_DIR="${HOME}/.dotfiles"
BACKUP_DIR="${HOME}/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

log_info "Backing up existing configurations..."

files_to_backup=(
  ".zshrc"
  ".tmux.conf"
  ".config/nvim"
  ".config/alacritty"
  ".config/hypr"
  ".config/waybar"
  ".config/swaync"
  ".config/rofi"
  ".config/wlogout"
  ".config/swayosd"
  ".config/hyprdynamicmonitors"
  ".config/ghostty"
  ".config/topgrade"
  ".config/k9s"
)

backed_up=0

for file in "${files_to_backup[@]}"; do
  if [ -e "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
    mkdir -p "$BACKUP_DIR"
    log_warning "Backing up $file"
    cp -r "$HOME/$file" "$BACKUP_DIR/"
    rm -rf "$HOME/$file"
    backed_up=1
  fi
done

if [ $backed_up -eq 1 ]; then
  log_success "Configs backed up to: $BACKUP_DIR"
else
  log_info "No existing configs to backup"
fi

log_info "Installing dotfiles with stow..."

cd "$DOTFILES_DIR" || exit 1

for dir in */; do
  pkg="${dir%/}"
  [[ "$pkg" == "install" ]] && continue
  [[ "$pkg" == ".git" ]] && continue
  [[ "$pkg" == ".sisyphus" ]] && continue
  
  log_info "Stowing $pkg..."
  stow -R -t "$HOME" "$pkg" 2>&1 || log_warning "Could not stow $pkg"
done

log_success "Dotfiles installed"
