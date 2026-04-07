#!/usr/bin/env bash
# Bootstrap installer (curl-friendly)
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/DanielePeruzzi97/dotfiles/main/install.sh | bash
#
# Optional env vars:
#   DOTFILES_REPO="owner/repo"        (default: DanielePeruzzi97/dotfiles)
#   DOTFILES_BRANCH="branch-name"     (default: feat/chezmoi-migration)

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

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

install_deps() {
    local distro
    distro=$(detect_distro)
    log_info "Detected distribution: $distro"

    case "$distro" in
        ubuntu|debian|pop)
            sudo apt update
            sudo apt install -y curl git
            ;;
        arch|manjaro|cachyos|endeavouros)
            sudo pacman -Sy --noconfirm curl git
            ;;
        fedora|rhel|centos)
            sudo dnf install -y curl git
            ;;
        *)
            log_error "Unsupported distribution: $distro"
            log_info "Install curl and git manually, then re-run this script"
            exit 1
            ;;
    esac
}

install_mise() {
    if command -v mise >/dev/null 2>&1; then
        log_warning "mise already installed: $(mise --version)"
        return 0
    fi

    log_info "Installing mise..."
    curl https://mise.run | sh
    export PATH="$HOME/.local/bin:$PATH"

    if ! command -v mise >/dev/null 2>&1; then
        log_error "mise installation failed"
        exit 1
    fi

    log_success "mise installed: $(mise --version)"
}

ensure_mise_activation() {
    if [ -f "$HOME/.bashrc" ] && ! grep -q "mise activate bash" "$HOME/.bashrc"; then
        echo 'eval "$(~/.local/bin/mise activate bash)"' >> "$HOME/.bashrc"
    fi

    if [ -f "$HOME/.profile" ] && ! grep -q "mise activate bash" "$HOME/.profile"; then
        echo 'eval "$(~/.local/bin/mise activate bash)"' >> "$HOME/.profile"
    fi

    export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"
}

ensure_chezmoi_command() {
    if command -v chezmoi >/dev/null 2>&1; then
        return 0
    fi

    local chezmoi_bin
    chezmoi_bin=$("$HOME/.local/bin/mise" which chezmoi 2>/dev/null || true)
    if [ -n "$chezmoi_bin" ] && [ -x "$chezmoi_bin" ]; then
        ln -sf "$chezmoi_bin" "$HOME/.local/bin/chezmoi"
        export PATH="$HOME/.local/bin:$PATH"
    fi
}

resolve_repo() {
    if [ -n "${DOTFILES_REPO:-}" ]; then
        echo "$DOTFILES_REPO"
        return
    fi

    if [ -n "${DOTFILES_GITHUB_USER:-}" ]; then
        echo "${DOTFILES_GITHUB_USER}/dotfiles"
        return
    fi

    echo "DanielePeruzzi97/dotfiles"
}

resolve_branch() {
    if [ -n "${DOTFILES_BRANCH:-}" ]; then
        echo "$DOTFILES_BRANCH"
        return
    fi

    # While migration is on a feature branch, default to it.
    # After merge, this should be switched back to main.
    echo "feat/chezmoi-migration"
}

repo_to_url() {
    local repo="$1"
    if [[ "$repo" == http://* || "$repo" == https://* || "$repo" == git@* ]]; then
        echo "$repo"
    else
        echo "https://github.com/${repo}.git"
    fi
}

clone_or_update_dotfiles_repo() {
    local repo="$1"
    local branch="$2"
    local url
    url=$(repo_to_url "$repo")

    if [ -d "$HOME/.dotfiles/.git" ]; then
        log_info "Updating existing ~/.dotfiles repository..."
        git -C "$HOME/.dotfiles" fetch origin "$branch"
        git -C "$HOME/.dotfiles" checkout "$branch"
        git -C "$HOME/.dotfiles" reset --hard "origin/$branch"
    else
        log_info "Cloning dotfiles into ~/.dotfiles (branch: $branch)..."
        git clone --branch "$branch" "$url" "$HOME/.dotfiles"
    fi
}

print_yubikey_hint() {
    echo ""
    log_info "YubiKey bootstrap (optional, recommended for private repo access):"
    echo "  1) Insert your YubiKey"
    echo "  2) Load resident SSH key: ssh-keygen -K"
    echo "  3) Move keys into ~/.ssh if needed and set permissions"
    echo "  4) Re-run: chezmoi apply"
    echo ""
}

main() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                  Dotfiles Bootstrap Installer               ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""

    if [ "${EUID}" -eq 0 ]; then
        log_error "Do not run this script as root"
        exit 1
    fi

    if ! command -v curl >/dev/null 2>&1 || ! command -v git >/dev/null 2>&1; then
        install_deps
    else
        log_success "curl and git already installed"
    fi

    install_mise
    ensure_mise_activation

    local repo
    local branch
    repo=$(resolve_repo)
    branch=$(resolve_branch)
    log_info "Applying dotfiles from: $repo (branch: $branch)"

    clone_or_update_dotfiles_repo "$repo" "$branch"

    "$HOME/.local/bin/mise" exec chezmoi@latest -- chezmoi init --source="$HOME/.dotfiles"
    "$HOME/.local/bin/mise" exec chezmoi@latest -- chezmoi apply --source="$HOME/.dotfiles"
    ensure_chezmoi_command

    log_success "Bootstrap complete"
    print_yubikey_hint

    echo "Next steps:"
    echo "  - Work machine/private repo: run ssh-keygen -K, then chezmoi apply"
    echo "  - Log out and back in to apply shell changes"
}

main "$@"
