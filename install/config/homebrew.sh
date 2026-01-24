#!/usr/bin/env bash
set -e

distro=$(detect_distro)

case "$distro" in
  arch|manjaro|cachyos|endeavouros)
    log_info "Skipping Homebrew on Arch-based distro (using native packages)"
    return 0
    ;;
esac

log_info "Installing Homebrew..."

if command_exists brew; then
  log_warning "Homebrew already installed"
  return 0
fi

NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

log_success "Homebrew installed"
