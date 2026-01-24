#!/usr/bin/env bash
set -e

log_info "Installing Hyprland plugins..."

if ! command_exists hyprpm; then
  log_warning "hyprpm not found - skipping plugin installation"
  return 0
fi

hyprpm update

if ! hyprpm list | grep -q "hyprsplit.*enabled: true"; then
  hyprpm add https://github.com/shezdy/hyprsplit
  hyprpm enable hyprsplit
  log_success "hyprsplit installed"
else
  log_warning "hyprsplit already installed"
fi

log_success "Hyprland plugins installed"
