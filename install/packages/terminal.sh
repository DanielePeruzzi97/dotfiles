#!/usr/bin/env bash
set -e

log_info "Installing terminal tools..."

if command_exists ghostty; then
  log_warning "Ghostty already installed"
else
  distro=$(detect_distro)
  
  case "$distro" in
    ubuntu|debian|pop)
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"
      ;;
    fedora|rhel|centos)
      install_dnf ghostty 2>/dev/null || log_warning "Ghostty not in repos - check COPR"
      ;;
    arch|manjaro|cachyos|endeavouros)
      install_pacman ghostty
      ;;
    *)
      log_warning "Ghostty installation not configured for $distro"
      ;;
  esac
  
  if command_exists ghostty; then
    log_success "Ghostty installed"
    sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/ghostty 50 2>/dev/null || true
  fi
fi

if command_exists topgrade; then
  log_warning "Topgrade already installed"
else
  distro=$(detect_distro)
  
  case "$distro" in
    arch|manjaro|cachyos|endeavouros)
      install_aur topgrade-bin
      ;;
    *)
      if command_exists cargo; then
        cargo install topgrade
      elif command_exists brew; then
        brew install topgrade
      else
        log_warning "Topgrade requires cargo or brew - skipping"
      fi
      ;;
  esac
  
  command_exists topgrade && log_success "Topgrade installed"
fi
