#!/usr/bin/env bash
set -e

log_info "Installing Flatpak applications..."

if ! command_exists flatpak; then
  log_warning "Flatpak not installed, skipping"
  return 0
fi

flatpak install -y --noninteractive flathub com.spotify.Client || true
flatpak install -y --noninteractive flathub com.discordapp.Discord || true
flatpak install -y --noninteractive flathub md.obsidian.Obsidian || true
flatpak install -y --noninteractive flathub com.bitwarden.desktop || true
flatpak install -y --noninteractive flathub io.dbeaver.DBeaverCommunity || true
flatpak install -y --noninteractive flathub org.gimp.GIMP || true
flatpak install -y --noninteractive flathub com.jgraph.drawio.desktop || true

log_success "Flatpak applications installed"
