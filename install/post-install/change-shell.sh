#!/usr/bin/env bash
set -e

log_info "Setting zsh as default shell..."

if [ "$SHELL" = "$(which zsh)" ]; then
  log_warning "zsh is already the default shell"
  return 0
fi

sudo chsh -s "$(which zsh)" "$USER"

log_success "Default shell changed to zsh"
