#!/usr/bin/env bash
set -e

log_info "Installing NVM..."

if [ -d "$HOME/.nvm" ]; then
  log_warning "NVM already installed"
  return 0
fi

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

log_success "NVM installed"
