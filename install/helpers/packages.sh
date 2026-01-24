#!/usr/bin/env bash
# Package manager abstractions

install_apt() {
  sudo apt install -y "$@"
}

install_dnf() {
  sudo dnf install -y "$@"
}

install_pacman() {
  sudo pacman -S --noconfirm "$@"
}

install_aur() {
  if command_exists yay; then
    yay -S --noconfirm "$@"
  elif command_exists paru; then
    paru -S --noconfirm "$@"
  else
    log_warning "No AUR helper found, skipping: $*"
    return 1
  fi
}

install_pkg() {
  local distro=$(detect_distro)
  case "$distro" in
    ubuntu|debian|pop) install_apt "$@" ;;
    fedora|rhel|centos) install_dnf "$@" ;;
    arch|manjaro|cachyos|endeavouros) install_pacman "$@" ;;
    *) log_error "Unsupported distro: $distro"; return 1 ;;
  esac
}
