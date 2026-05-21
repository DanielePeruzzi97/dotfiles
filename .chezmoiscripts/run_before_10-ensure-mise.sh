#!/bin/bash
# Ensure mise is installed and in PATH
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }

# Check if mise is already available
if command -v mise &> /dev/null; then
    log_success "mise already installed: $(mise --version)"
    exit 0
fi

# Check in common locations
if [ -x "$HOME/.local/bin/mise" ]; then
    log_success "mise found at ~/.local/bin/mise"
    exit 0
fi

# Install mise
log_info "Installing mise..."
curl https://mise.run | sh

if [ -x "$HOME/.local/bin/mise" ]; then
    log_success "mise installed successfully"
else
    echo "ERROR: mise installation failed"
    exit 1
fi
