#!/usr/bin/env bash
set -e

log_info "Installing Neovim..."

if command_exists nvim; then
  log_warning "Neovim already installed: $(nvim --version | head -n1)"
  return 0
fi

distro=$(detect_distro)

case "$distro" in
  ubuntu|debian|pop)
    sudo add-apt-repository -y ppa:neovim-ppa/unstable
    sudo apt update
    install_apt neovim
    ;;
  fedora|rhel|centos)
    install_dnf neovim
    ;;
  arch|manjaro|cachyos|endeavouros)
    install_pacman neovim
    ;;
  *)
    log_info "Installing Neovim from AppImage..."
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    chmod u+x nvim.appimage
    sudo mv nvim.appimage /usr/local/bin/nvim
    ;;
esac

log_success "Neovim installed"
