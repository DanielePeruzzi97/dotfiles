#!/bin/bash
# Bootstrap script for setting up a new machine with dotfiles
# Usage: curl -fsSL https://raw.githubusercontent.com/YOUR_USER/dotfiles/main/setup.sh | bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Detect distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    elif [ -f /etc/arch-release ]; then
        echo "arch"
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    else
        echo "unknown"
    fi
}

# Install minimal dependencies
install_deps() {
    local distro=$(detect_distro)
    log_info "Detected distribution: $distro"
    
    case "$distro" in
        ubuntu|debian|pop)
            log_info "Installing dependencies via apt..."
            sudo apt update
            sudo apt install -y curl git
            ;;
        arch|manjaro|cachyos|endeavouros)
            log_info "Installing dependencies via pacman..."
            sudo pacman -Sy --noconfirm curl git
            ;;
        fedora|rhel|centos)
            log_info "Installing dependencies via dnf..."
            sudo dnf install -y curl git
            ;;
        *)
            log_error "Unsupported distribution: $distro"
            log_info "Please install curl and git manually, then re-run this script"
            exit 1
            ;;
    esac
}

# Install mise
install_mise() {
    if command -v mise &> /dev/null; then
        log_warning "mise already installed: $(mise --version)"
        return 0
    fi
    
    log_info "Installing mise..."
    curl https://mise.run | sh
    
    # Add mise to PATH for this session
    export PATH="$HOME/.local/bin:$PATH"
    
    if command -v mise &> /dev/null; then
        log_success "mise installed: $(mise --version)"
    else
        log_error "mise installation failed"
        exit 1
    fi
}

# Main bootstrap
main() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║               Dotfiles Bootstrap Script                      ║"
    echo "║         Setting up your development environment              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Check if running as root
    if [ "$EUID" -eq 0 ]; then
        log_error "Please do not run this script as root"
        exit 1
    fi
    
    # Install minimal dependencies
    if ! command -v curl &> /dev/null || ! command -v git &> /dev/null; then
        install_deps
    else
        log_success "curl and git already installed"
    fi
    
    # Install mise
    install_mise
    
    # Determine GitHub username for dotfiles
    GITHUB_USER="${DOTFILES_GITHUB_USER:-}"
    if [ -z "$GITHUB_USER" ]; then
        log_info "Enter your GitHub username (for cloning dotfiles):"
        read -r GITHUB_USER
    fi
    
    if [ -z "$GITHUB_USER" ]; then
        log_error "GitHub username is required"
        exit 1
    fi
    
    # Use mise to run chezmoi (auto-installs it)
    log_info "Initializing dotfiles with chezmoi..."
    
    # Run chezmoi init and apply
    ~/.local/bin/mise exec chezmoi@latest -- chezmoi init --apply "$GITHUB_USER"
    
    echo ""
    log_success "Bootstrap complete!"
    echo ""
    echo "Next steps:"
    echo "  1. If this is a work machine, set up your SSH key for private dotfiles:"
    echo "     - Extract from YubiKey: ssh-keygen -K"
    echo "     - Or generate new: ssh-keygen -t ed25519"
    echo "  2. Then run: chezmoi update"
    echo "  3. Log out and back in to apply shell changes"
    echo ""
}

main "$@"
