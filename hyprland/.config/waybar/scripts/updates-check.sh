#!/bin/bash
# Check for available system updates across all package managers
# Outputs JSON for waybar consumption

distro=""
if [ -f /etc/os-release ]; then
    . /etc/os-release
    distro="$ID"
fi

total=0
tooltip=""

case "$distro" in
    ubuntu|debian|pop)
        count=$(apt list --upgradable 2>/dev/null | grep -c upgradable || echo 0)
        count=${count:-0}
        total=$((total + count))
        [ "$count" -gt 0 ] && tooltip+="APT: $count\n"
        ;;
    arch|manjaro|cachyos|endeavouros)
        pacman_count=$(checkupdates 2>/dev/null | wc -l || echo 0)
        pacman_count=${pacman_count:-0}
        total=$((total + pacman_count))
        [ "$pacman_count" -gt 0 ] && tooltip+="Pacman: $pacman_count\n"
        
        if command -v yay >/dev/null 2>&1; then
            aur_count=$(yay -Qu --aur 2>/dev/null | wc -l || echo 0)
            aur_count=${aur_count:-0}
            total=$((total + aur_count))
            [ "$aur_count" -gt 0 ] && tooltip+="AUR: $aur_count\n"
        elif command -v paru >/dev/null 2>&1; then
            aur_count=$(paru -Qu --aur 2>/dev/null | wc -l || echo 0)
            aur_count=${aur_count:-0}
            total=$((total + aur_count))
            [ "$aur_count" -gt 0 ] && tooltip+="AUR: $aur_count\n"
        fi
        ;;
    fedora)
        count=$(dnf check-update --quiet 2>/dev/null | grep -c "^[a-zA-Z]" || echo 0)
        count=${count:-0}
        total=$((total + count))
        [ "$count" -gt 0 ] && tooltip+="DNF: $count\n"
        ;;
esac

if command -v flatpak >/dev/null 2>&1; then
    flatpak_count=$(flatpak remote-ls --updates 2>/dev/null | wc -l || echo 0)
    flatpak_count=${flatpak_count:-0}
    total=$((total + flatpak_count))
    [ "$flatpak_count" -gt 0 ] && tooltip+="Flatpak: $flatpak_count\n"
fi

if command -v brew >/dev/null 2>&1; then
    brew_count=$(brew outdated 2>/dev/null | wc -l || echo 0)
    brew_count=${brew_count:-0}
    total=$((total + brew_count))
    [ "$brew_count" -gt 0 ] && tooltip+="Brew: $brew_count\n"
fi

if [ "$total" -gt 0 ]; then
    tooltip+="Click to update"
    echo "{\"text\": \"󰚰 $total\", \"tooltip\": \"$tooltip\", \"class\": \"updates-available\"}"
else
    echo ""
fi
