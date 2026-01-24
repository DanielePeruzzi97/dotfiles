#!/usr/bin/env bash
set -e

log_info "Installing base system packages..."

distro=$(detect_distro)

case "$distro" in
  ubuntu|debian|pop)
    sudo apt update
    install_apt zsh git stow tmux curl wget xclip fzf fd-find ripgrep \
      build-essential python3-pip unzip fontconfig zoxide
    
    if ! command_exists lazygit; then
      LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
      curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
      tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
      sudo install /tmp/lazygit /usr/local/bin
      rm -f /tmp/lazygit.tar.gz /tmp/lazygit
    fi
    
    if command_exists fdfind && ! command_exists fd; then
      sudo ln -sf $(which fdfind) /usr/local/bin/fd
    fi
    ;;

  fedora|rhel|centos)
    install_dnf zsh git stow tmux curl wget xclip fzf fd-find ripgrep \
      gcc gcc-c++ make python3-pip unzip fontconfig lazygit zoxide
    ;;

  arch|manjaro|cachyos|endeavouros)
    install_pacman zsh git stow tmux curl wget xclip fzf fd ripgrep \
      base-devel python-pip unzip fontconfig lazygit zoxide
    
    if ! command_exists yay && ! command_exists paru; then
      log_info "Installing yay AUR helper..."
      git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
      (cd /tmp/yay-bin && makepkg -si --noconfirm)
      rm -rf /tmp/yay-bin
    fi
    ;;

  *)
    log_error "Unsupported distribution: $distro"
    exit 1
    ;;
esac

log_success "Base packages installed"
