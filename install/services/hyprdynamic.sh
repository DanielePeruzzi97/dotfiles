#!/usr/bin/env bash
set -e

log_info "Installing HyprDynamicMonitors..."

if ! command_exists hyprdynamicmonitors; then
  distro=$(detect_distro)

  case "$distro" in
    arch|manjaro|cachyos|endeavouros)
      install_aur hyprdynamicmonitors
      ;;
    *)
      LATEST_RELEASE=$(curl -s https://api.github.com/repos/fiffeek/hyprdynamicmonitors/releases/latest | grep tag_name | cut -d '"' -f 4)
      DOWNLOAD_URL="https://github.com/fiffeek/hyprdynamicmonitors/releases/download/${LATEST_RELEASE}/hyprdynamicmonitors-${LATEST_RELEASE}-linux-amd64.tar.gz"
      
      wget "$DOWNLOAD_URL" -O /tmp/hyprdynamicmonitors.tar.gz
      tar -xzf /tmp/hyprdynamicmonitors.tar.gz -C /tmp
      chmod +x /tmp/hyprdynamicmonitors
      sudo mv /tmp/hyprdynamicmonitors /usr/local/bin/
      rm -f /tmp/hyprdynamicmonitors.tar.gz
      ;;
  esac

  if command_exists hyprdynamicmonitors; then
    log_success "hyprdynamicmonitors installed"
  fi
else
  log_warning "hyprdynamicmonitors already installed"
fi

# Install systemd user service
SERVICE_SRC="$DOTFILES_DIR/hyprland/.config/hyprdynamicmonitors/hyprdynamicmonitors.service"
SERVICE_DST="$HOME/.config/systemd/user/hyprdynamicmonitors.service"

if [[ -f "$SERVICE_SRC" ]]; then
  mkdir -p "$HOME/.config/systemd/user"
  cp "$SERVICE_SRC" "$SERVICE_DST"
  systemctl --user daemon-reload
  systemctl --user enable hyprdynamicmonitors.service
  log_success "hyprdynamicmonitors systemd service installed and enabled"
fi
