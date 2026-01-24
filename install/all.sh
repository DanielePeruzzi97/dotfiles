#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/helpers/logging.sh"
source "$SCRIPT_DIR/helpers/detect.sh"
source "$SCRIPT_DIR/helpers/packages.sh"

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║       Dotfiles Installation              ║"
echo "╚══════════════════════════════════════════╝"
echo ""

MINIMAL=false
NO_DESKTOP=false
NO_K8S=false
NO_FLATPAK=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --minimal) MINIMAL=true; shift ;;
    --no-desktop) NO_DESKTOP=true; shift ;;
    --no-k8s) NO_K8S=true; shift ;;
    --no-flatpak) NO_FLATPAK=true; shift ;;
    --help)
      echo "Usage: ./install/all.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --minimal     Skip desktop, Hyprland, k8s, flatpak"
      echo "  --no-desktop  Skip desktop apps"
      echo "  --no-k8s      Skip Kubernetes tools"
      echo "  --no-flatpak  Skip Flatpak apps"
      exit 0
      ;;
    *) log_warning "Unknown option: $1"; shift ;;
  esac
done

log_info "Detected: $(detect_distro) ($(detect_arch))"
echo ""

source "$SCRIPT_DIR/packages/base.sh"
source "$SCRIPT_DIR/packages/neovim.sh"
source "$SCRIPT_DIR/config/homebrew.sh"
source "$SCRIPT_DIR/packages/terminal.sh"
source "$SCRIPT_DIR/config/shell.sh"
source "$SCRIPT_DIR/config/nvm.sh"
source "$SCRIPT_DIR/config/go.sh"
source "$SCRIPT_DIR/config/fonts.sh"
source "$SCRIPT_DIR/config/tmux.sh"

if [[ "$MINIMAL" == false ]]; then
  if [[ "$NO_K8S" == false ]]; then
    source "$SCRIPT_DIR/packages/k8s.sh"
  fi
  
  if [[ "$NO_DESKTOP" == false ]]; then
    source "$SCRIPT_DIR/packages/desktop.sh"
    source "$SCRIPT_DIR/packages/hyprland.sh"
    source "$SCRIPT_DIR/services/hyprdynamic.sh"
  fi
  
  if [[ "$NO_FLATPAK" == false ]]; then
    source "$SCRIPT_DIR/packages/flatpak.sh"
  fi
fi

source "$SCRIPT_DIR/stow/apply.sh"

if [[ "$MINIMAL" == false && "$NO_DESKTOP" == false ]]; then
  source "$SCRIPT_DIR/services/systemd.sh"
  source "$SCRIPT_DIR/post-install/hyprland-plugins.sh"
fi

source "$SCRIPT_DIR/post-install/change-shell.sh"

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║       Installation Complete!             ║"
echo "╚══════════════════════════════════════════╝"
echo ""
log_info "Next steps:"
echo "  1. Log out and back in (or: exec zsh)"
echo "  2. In tmux: Alt+a then I (install plugins)"
echo "  3. In nvim: plugins auto-install"
echo "  4. For Hyprland: hyprpm reload"
echo ""
