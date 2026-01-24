#!/usr/bin/env bash
set -e

log_info "Installing Hyprland desktop packages..."

distro=$(detect_distro)

case "$distro" in
  ubuntu|debian|pop)
    install_apt waybar sway-notification-center rofi swayosd wlogout cliphist \
      wl-clipboard brightnessctl playerctl udiskie polkit-kde-agent-1 \
      network-manager-gnome blueman pavucontrol grim slurp hyprsunset \
      nautilus qt5ct qt6ct xdg-user-dirs xdg-desktop-portal-gtk gvfs tumbler btop
    
    install_apt hyprlock hypridle hyprpaper grimblast 2>/dev/null || \
      log_warning "hyprlock/hypridle/hyprpaper not found - add Hyprland PPA"
    ;;

  fedora|rhel|centos)
    install_dnf waybar SwayNotificationCenter rofi-wayland swayosd wlogout cliphist \
      wl-clipboard brightnessctl playerctl udiskie polkit-kde network-manager-applet \
      blueman pavucontrol grim slurp hyprlock hypridle hyprpaper hyprsunset \
      nautilus qt5ct qt6ct xdg-user-dirs xdg-desktop-portal-gtk gvfs tumbler btop
    
    install_dnf grimblast 2>/dev/null || log_warning "grimblast not found"
    ;;

  arch|manjaro|cachyos|endeavouros)
    install_pacman waybar rofi-wayland wlogout cliphist wl-clipboard brightnessctl \
      playerctl udiskie polkit-kde-agent network-manager-applet blueman pavucontrol \
      grim slurp hyprlock hypridle hyprpaper hyprsunset nautilus qt5ct qt6ct \
      xdg-user-dirs xdg-desktop-portal-gtk gvfs tumbler btop
    
    install_aur swaync swayosd-git grimblast-git hyprshot rofi-calc
    ;;

  *)
    log_warning "Hyprland packages not configured for $distro"
    return 1
    ;;
esac

log_success "Hyprland packages installed"
