#!/usr/bin/env bash
# Dotfiles bootstrap.
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/DanielePeruzzi97/dotfiles/main/install.sh | bash
#
# Optional env:
#   DOTFILES_REPO   "owner/repo"   (default: DanielePeruzzi97/dotfiles)
#   DOTFILES_BRANCH "branch"       (default: main)

set -euo pipefail

REPO="${DOTFILES_REPO:-DanielePeruzzi97/dotfiles}"
BRANCH="${DOTFILES_BRANCH:-main}"
DEST="$HOME/.dotfiles"

c_blue='\033[0;34m'; c_grn='\033[0;32m'; c_red='\033[0;31m'; c_off='\033[0m'
info() { printf "${c_blue}[*]${c_off} %s\n" "$*"; }
ok()   { printf "${c_grn}[+]${c_off} %s\n" "$*"; }
die()  { printf "${c_red}[!]${c_off} %s\n" "$*" >&2; exit 1; }

[ "${EUID}" -eq 0 ] && die "Do not run as root."

# --- Distro guard: arch + ubuntu 25.10 only -----------------------------------
. /etc/os-release
case "${ID}:${VERSION_CODENAME:-}" in
    arch:*)             PM="pacman" ;;
    ubuntu:questing)    PM="apt"    ;;
    *) die "Unsupported distro: ${ID} ${VERSION_CODENAME:-}. Supported: arch, ubuntu 25.10 (questing)." ;;
esac
ok "Distro: ${ID} ${VERSION_CODENAME:-} (${PM})"

# --- Base deps (curl + git) ---------------------------------------------------
if ! command -v curl >/dev/null || ! command -v git >/dev/null; then
    info "Installing curl + git"
    case "$PM" in
        apt)    sudo apt update && sudo apt install -y curl git ;;
        pacman) sudo pacman -Sy --noconfirm curl git ;;
    esac
fi

# --- mise ---------------------------------------------------------------------
if [ ! -x "$HOME/.local/bin/mise" ] && ! command -v mise >/dev/null; then
    info "Installing mise"
    curl -fsSL https://mise.run | sh
fi
export PATH="$HOME/.local/bin:$PATH"
MISE="$HOME/.local/bin/mise"

# --- Clone / update repo ------------------------------------------------------
if [ -d "$DEST/.git" ]; then
    info "Updating $DEST"
    git -C "$DEST" fetch origin "$BRANCH"
    git -C "$DEST" checkout "$BRANCH"
    git -C "$DEST" reset --hard "origin/$BRANCH"
else
    info "Cloning $REPO ($BRANCH) → $DEST"
    git clone --branch "$BRANCH" "https://github.com/${REPO}.git" "$DEST"
fi

# --- chezmoi init + apply -----------------------------------------------------
info "chezmoi init"
"$MISE" exec chezmoi@latest -- chezmoi init --source="$DEST"

info "chezmoi apply"
"$MISE" exec chezmoi@latest -- chezmoi apply --source="$DEST"

# Convenience symlink so `chezmoi` is on PATH without `mise exec`.
chezmoi_bin="$($MISE which chezmoi 2>/dev/null || true)"
[ -n "$chezmoi_bin" ] && ln -sf "$chezmoi_bin" "$HOME/.local/bin/chezmoi"

ok "Done."
echo
echo "Next:"
echo "  - Log out and back in to apply shell + session changes."
echo "  - Private dotfiles? See: https://github.com/DanielePeruzzi97/dotfiles_private"
