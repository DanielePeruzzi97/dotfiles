#!/usr/bin/env bash
set -e

log_info "Setting up HyprDynamicMonitors systemd service..."

SERVICE_SOURCE="$HOME/.config/hyprdynamicmonitors/hyprdynamicmonitors.service"
SERVICE_DEST="/etc/systemd/user/hyprdynamicmonitors.service"

if [ -f "$SERVICE_SOURCE" ]; then
  sudo cp "$SERVICE_SOURCE" "$SERVICE_DEST"
  sudo chmod 644 "$SERVICE_DEST"
  
  systemctl --user daemon-reload
  systemctl --user enable hyprdynamicmonitors.service
  
  log_success "HyprDynamicMonitors systemd service enabled"
else
  log_warning "HyprDynamicMonitors service file not found"
fi
