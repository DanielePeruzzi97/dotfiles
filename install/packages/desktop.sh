#!/usr/bin/env bash
set -e

log_info "Installing desktop applications..."

distro=$(detect_distro)

case "$distro" in
  ubuntu|debian|pop)
    install_apt loupe gnome-text-editor file-roller \
      seahorse mpv gnome-firmware flatpak awscli curl jq tree btop iotop nethogs sshfs
    ;;

  fedora|rhel|centos)
    install_dnf loupe gnome-text-editor file-roller \
      seahorse mpv gnome-firmware flatpak awscli2 curl jq tree btop iotop nethogs sshfs
    ;;

  arch|manjaro|cachyos|endeavouros)
    install_pacman loupe gnome-text-editor file-roller \
      seahorse mpv flatpak aws-cli curl jq tree btop iotop nethogs sshfs \
      reflector pkgfile pacman-contrib
    
    install_aur gnome-firmware session-manager-plugin rate-mirrors paru
    sudo pkgfile --update 2>/dev/null || true
    ;;

  *)
    log_warning "Desktop apps not configured for $distro"
    return 0
    ;;
esac

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

log_success "Desktop applications installed"
