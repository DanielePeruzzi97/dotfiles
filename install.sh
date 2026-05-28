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

c_blue='\033[0;34m'; c_grn='\033[0;32m'; c_red='\033[0;31m'; c_yel='\033[1;33m'; c_off='\033[0m'
info() { printf "${c_blue}[*]${c_off} %s\n" "$*"; }
ok()   { printf "${c_grn}[+]${c_off} %s\n" "$*"; }
warn() { printf "${c_yel}[!]${c_off} %s\n" "$*"; }
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

# Helper: run chezmoi via mise (no symlink dependency)
chezmoi() { "$MISE" exec chezmoi@latest -- chezmoi "$@"; }

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

# --- chezmoi init -------------------------------------------------------------
info "chezmoi init"
# Redirect stdin from /dev/tty so stdinIsATTY=true even when run via curl|bash
chezmoi init --source="$DEST" </dev/tty

# --- Phase 1: apply public content --------------------------------------------
# Personal .age files will fail gracefully if age key not yet present.
# The packages script (run_onchange_before_05) installs bw CLI in this phase.
info "chezmoi apply (phase 1 — public content)"
chezmoi apply --source="$DEST" --keep-going || true

# --- Phase 2: personal content (age-encrypted) --------------------------------
# Only triggered when personal=true was answered on chezmoi init.
PERSONAL=$(chezmoi data --format=json \
    | python3 -c "import sys,json; d=json.load(sys.stdin); print(str(d.get('personal',False)).lower())" \
    2>/dev/null || echo "false")

if [ "$PERSONAL" = "true" ]; then
    KEY_FILE="$HOME/.config/chezmoi/key.txt"
    if [ ! -f "$KEY_FILE" ]; then
        info "Personal machine — fetching age key from Bitwarden"
        if command -v bw &>/dev/null; then
            # </dev/tty: interactive prompts work even when run via curl|bash
            bw login --check &>/dev/null || bw login </dev/tty || die "Bitwarden login failed"
            BW_SESSION=$(bw unlock --raw </dev/tty) || die "Bitwarden unlock failed"
            export BW_SESSION
            mkdir -p "$(dirname "$KEY_FILE")"
            bw get notes "chezmoi-age-key" --session "$BW_SESSION" > "$KEY_FILE" \
                || die "Failed to fetch 'chezmoi-age-key' note from Bitwarden vault"
            chmod 600 "$KEY_FILE"
            ok "Age key fetched"
        else
            warn "bw CLI not found. Install it and run: chezmoi apply"
            warn "  Ubuntu: flatpak install flathub com.bitwarden.desktop"
            warn "  Arch:   paru -S bitwarden-cli"
            warn "Then: bw login && chezmoi apply"
        fi
    fi

    if [ -f "$KEY_FILE" ]; then
        info "chezmoi apply (phase 2 — personal content)"
        chezmoi apply --source="$DEST"
    fi
fi

# Convenience symlink so `chezmoi` is on PATH after install
chezmoi_bin="$("$MISE" which chezmoi 2>/dev/null || true)"
[ -n "$chezmoi_bin" ] && ln -sf "$chezmoi_bin" "$HOME/.local/bin/chezmoi"

ok "Done."
echo
echo "Next:"
echo "  - Log out and back in to apply shell + session changes."
if [ "$PERSONAL" = "true" ]; then
    echo "  - Work dotfiles: run_after_90 will clone dotfiles_work automatically on next apply."
fi
