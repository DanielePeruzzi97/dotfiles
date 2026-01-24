#!/usr/bin/env bash
set -e

log_info "Installing Go..."

if command_exists go; then
  log_warning "Go already installed: $(go version)"
  return 0
fi

GO_VERSION="1.21.5"
ARCH=$(detect_arch)

wget "https://go.dev/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz" -O /tmp/go.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf /tmp/go.tar.gz
rm /tmp/go.tar.gz

log_success "Go installed"
