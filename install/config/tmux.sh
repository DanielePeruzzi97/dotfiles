#!/usr/bin/env bash
set -e

log_info "Setting up Tmux (TPM)..."

if [ -d "$HOME/.tmux/plugins/tpm" ]; then
  log_warning "TPM already installed"
  return 0
fi

git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"

log_success "TPM installed (run prefix+I in tmux to install plugins)"
