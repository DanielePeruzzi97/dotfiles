#!/usr/bin/env bash
set -e

log_info "Installing Nerd Fonts..."

FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

if ls "$FONT_DIR"/JetBrainsMonoNerd* 1>/dev/null 2>&1; then
  log_warning "JetBrainsMono Nerd Font already installed"
  return 0
fi

wget "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip" -O /tmp/JetBrainsMono.zip
unzip -o /tmp/JetBrainsMono.zip -d "$FONT_DIR" "*.ttf"
rm /tmp/JetBrainsMono.zip

fc-cache -fv

log_success "JetBrainsMono Nerd Font installed"
