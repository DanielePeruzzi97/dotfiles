#!/usr/bin/env bash
#
# Dotfiles Installation Script
# Automates the setup of a fresh Linux installation with all required tools
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories
DOTFILES_DIR="${HOME}/.dotfiles"
BACKUP_DIR="${HOME}/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# Logging functions
log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Detect Linux distribution
detect_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "$ID"
  else
    log_error "Cannot detect Linux distribution"
    exit 1
  fi
}

# Install system packages based on distro
install_system_packages() {
  log_info "Phase 1: Installing system packages..."

  local distro=$(detect_distro)

  case "$distro" in
  ubuntu | debian | pop)
    log_info "Detected Debian/Ubuntu-based system"
    sudo apt update
    sudo apt install -y \
      zsh \
      git \
      stow \
      tmux \
      curl \
      wget \
      xclip \
      fzf \
      fd-find \
      ripgrep \
      build-essential \
      python3-pip \
      unzip \
      fontconfig \
      lazygit \
      zoxide

    # Create symlink for fd if it doesn't exist
    if command_exists fdfind && ! command_exists fd; then
      sudo ln -sf $(which fdfind) /usr/local/bin/fd
    fi
    
    # Install yazi if not available in repos (newer package)
    if ! command_exists yazi; then
      log_info "yazi not in repos, will install via cargo or download binary"
    fi
    ;;

  fedora | rhel | centos)
    log_info "Detected Fedora/RHEL-based system"
    sudo dnf install -y \
      zsh \
      git \
      stow \
      tmux \
      curl \
      wget \
      xclip \
      fzf \
      fd-find \
      ripgrep \
      gcc \
      gcc-c++ \
      make \
      python3-pip \
      unzip \
      fontconfig \
      lazygit \
      zoxide
    ;;

  arch | manjaro)
    log_info "Detected Arch-based system"
    sudo pacman -Sy --noconfirm \
      zsh \
      git \
      stow \
      tmux \
      curl \
      wget \
      xclip \
      fzf \
      fd \
      ripgrep \
      base-devel \
      python-pip \
      unzip \
      fontconfig \
      lazygit \
      zoxide \
      yazi
    ;;


  *)
    log_error "Unsupported distribution: $distro"
    log_warning "Please install packages manually: zsh git stow tmux curl wget xclip fzf fd ripgrep"
    return 1
    ;;
  esac

  log_success "System packages installed"
}

# Install Neovim (latest stable)
install_neovim() {
  log_info "Phase 2: Installing Neovim..."

  if command_exists nvim; then
    log_warning "Neovim already installed: $(nvim --version | head -n1)"
    return 0
  fi

  local distro=$(detect_distro)

  case "$distro" in
  ubuntu | debian | pop)
    # Install from official PPA for latest version
    sudo add-apt-repository -y ppa:neovim-ppa/unstable
    sudo apt update
    sudo apt install -y neovim
    ;;
  fedora | rhel | centos)
    sudo dnf install -y neovim
    ;;
  arch | manjaro)
    sudo pacman -S --noconfirm neovim
    ;;
  *)
    log_warning "Installing Neovim from AppImage..."
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    chmod u+x nvim.appimage
    sudo mv nvim.appimage /usr/local/bin/nvim
    ;;
  esac

  log_success "Neovim installed"
}

# Install Homebrew for additional tools
install_homebrew() {
  log_info "Phase 3: Installing Homebrew..."

  if command_exists brew; then
    log_warning "Homebrew already installed"
    return 0
  fi

  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add brew to PATH for this session
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

  log_success "Homebrew installed"
}

# Install tools from Homebrew
install_brew_tools() {
  log_info "Phase 4: Installing tools from Homebrew..."

  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

  # Install tools that are ONLY available via brew or easier to update
  # k9s is already installed in Phase 8 via brew
  # Most other tools should use system package managers
  
  # Currently keeping Homebrew minimal - only for tools not in system repos
  log_info "Homebrew kept minimal - install additional tools via system package manager"

  log_success "Brew tools installed"
}

# Install oh-my-zsh and plugins
install_oh_my_zsh() {
  log_info "Phase 5: Installing oh-my-zsh..."

  if [ -d "$HOME/.oh-my-zsh" ]; then
    log_warning "oh-my-zsh already installed"
  else
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    log_success "oh-my-zsh installed"
  fi

  # Install custom plugins
  local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  # zsh-syntax-highlighting
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    log_info "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
      "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  fi

  # zsh-autosuggestions
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    log_info "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions.git \
      "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  fi

  # zsh-history-substring-search
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-history-substring-search" ]; then
    log_info "Installing zsh-history-substring-search..."
    git clone https://github.com/zsh-users/zsh-history-substring-search.git \
      "$ZSH_CUSTOM/plugins/zsh-history-substring-search"
  fi

  log_success "oh-my-zsh plugins installed"
}

# Install NVM (Node Version Manager)
install_nvm() {
  log_info "Phase 6: Installing NVM..."

  if [ -d "$HOME/.nvm" ]; then
    log_warning "NVM already installed"
    return 0
  fi

  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

  # Load NVM
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

  log_success "NVM installed"
}

# Install Go
install_go() {
  log_info "Phase 7: Installing Go..."

  if command_exists go; then
    log_warning "Go already installed: $(go version)"
    return 0
  fi

  local GO_VERSION="1.21.5"
  local ARCH=$(uname -m)

  case "$ARCH" in
  x86_64)
    ARCH="amd64"
    ;;
  aarch64)
    ARCH="arm64"
    ;;
  esac

  wget "https://go.dev/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz" -O /tmp/go.tar.gz
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf /tmp/go.tar.gz
  rm /tmp/go.tar.gz

  log_success "Go installed"
}

# Install Kubernetes and Homelab tools
install_k8s_tools() {
  log_info "Phase 8: Installing Kubernetes and Homelab tools..."

  # Install kubectl
  if ! command_exists kubectl; then
    log_info "Installing kubectl..."
    local KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
    log_success "kubectl ${KUBECTL_VERSION} installed"
  else
    log_warning "kubectl already installed: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
  fi

  # Install Helm
  if ! command_exists helm; then
    log_info "Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    log_success "Helm installed"
  else
    log_warning "Helm already installed: $(helm version --short)"
  fi

  # Install Talosctl
  if ! command_exists talosctl; then
    log_info "Installing Talosctl..."
    curl -sL https://talos.dev/install | sh
    log_success "Talosctl installed"
  else
    log_warning "Talosctl already installed: $(talosctl version --client --short 2>/dev/null || echo 'version check failed')"
  fi

  # Install k9s (via Homebrew for easier updates)
  if ! command_exists k9s; then
    log_info "Installing k9s..."
    if command_exists brew; then
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
      brew install derailed/k9s/k9s
      log_success "k9s installed"
    else
      log_warning "Homebrew not found, skipping k9s installation"
    fi
  else
    log_warning "k9s already installed"
  fi

  # Install kubeseal (Sealed Secrets CLI)
  if ! command_exists kubeseal; then
    log_info "Installing kubeseal..."
    local KUBESEAL_VERSION=$(curl -s https://api.github.com/repos/bitnami-labs/sealed-secrets/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')
    wget "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz" -O /tmp/kubeseal.tar.gz
    tar -xzf /tmp/kubeseal.tar.gz -C /tmp kubeseal
    chmod +x /tmp/kubeseal
    sudo mv /tmp/kubeseal /usr/local/bin/
    rm /tmp/kubeseal.tar.gz
    log_success "kubeseal v${KUBESEAL_VERSION} installed"
  else
    log_warning "kubeseal already installed: $(kubeseal --version 2>/dev/null | grep version || echo 'version check failed')"
  fi

  # Install SOPS (Secrets OPerationS)
  if ! command_exists sops; then
    log_info "Installing SOPS..."
    local SOPS_VERSION=$(curl -s https://api.github.com/repos/getsops/sops/releases/latest | grep tag_name | cut -d '"' -f 4)
    wget "https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.amd64" -O /tmp/sops
    chmod +x /tmp/sops
    sudo mv /tmp/sops /usr/local/bin/
    log_success "SOPS ${SOPS_VERSION} installed"
  else
    log_warning "SOPS already installed: $(sops --version 2>/dev/null | head -1 || echo 'version check failed')"
  fi

  # Install age (encryption tool for SOPS)
  if ! command_exists age; then
    log_info "Installing age..."
    local AGE_VERSION=$(curl -s https://api.github.com/repos/FiloSottile/age/releases/latest | grep tag_name | cut -d '"' -f 4)
    wget "https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/age-${AGE_VERSION}-linux-amd64.tar.gz" -O /tmp/age.tar.gz
    tar -xzf /tmp/age.tar.gz -C /tmp
    chmod +x /tmp/age/age /tmp/age/age-keygen
    sudo mv /tmp/age/age /tmp/age/age-keygen /usr/local/bin/
    rm -rf /tmp/age.tar.gz /tmp/age
    log_success "age ${AGE_VERSION} installed"
  else
    log_warning "age already installed: $(age --version 2>/dev/null || echo 'version check failed')"
  fi

  log_success "Kubernetes and Homelab tools installation complete"
}

# Install a Nerd Font
install_nerd_font() {
  log_info "Phase 9: Installing Nerd Font (JetBrainsMono)..."

  local FONT_DIR="$HOME/.local/share/fonts"
  mkdir -p "$FONT_DIR"

  if ls "$FONT_DIR"/JetBrainsMonoNerd* 1>/dev/null 2>&1; then
    log_warning "JetBrainsMono Nerd Font already installed"
    return 0
  fi

  local FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip"

  wget "$FONT_URL" -O /tmp/JetBrainsMono.zip
  unzip -o /tmp/JetBrainsMono.zip -d "$FONT_DIR" "*.ttf"
  rm /tmp/JetBrainsMono.zip

  # Refresh font cache
  fc-cache -fv

  log_success "JetBrainsMono Nerd Font installed"
}

# Install TPM (Tmux Plugin Manager)
install_tpm() {
  log_info "Phase 10: Installing TPM (Tmux Plugin Manager)..."

  if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    log_warning "TPM already installed"
    return 0
  fi

  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"

  log_success "TPM installed"
  log_info "Run 'prefix + I' in tmux to install plugins (prefix = Alt+a)"
}

# Backup existing dotfiles
backup_existing_configs() {
  log_info "Phase 11: Backing up existing configurations..."

  local files_to_backup=(
    ".zshrc"
    ".tmux.conf"
    ".config/nvim"
    ".config/alacritty"
  )

  local backed_up=0

  for file in "${files_to_backup[@]}"; do
    if [ -e "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
      mkdir -p "$BACKUP_DIR"
      log_warning "Backing up existing $file"
      cp -r "$HOME/$file" "$BACKUP_DIR/"
      backed_up=1
    fi
  done

  if [ $backed_up -eq 1 ]; then
    log_success "Existing configs backed up to: $BACKUP_DIR"
  else
    log_info "No existing configs to backup"
  fi
}

# Stow dotfiles
stow_dotfiles() {
  log_info "Phase 12: Installing dotfiles with stow..."

  cd "$DOTFILES_DIR" || {
    log_error "Could not cd into $DOTFILES_DIR"
    exit 1
  }

  # Remove existing symlinks to avoid conflicts
  for dir in */; do
    pkg="${dir%/}"
    log_info "Stowing $pkg..."
    stow -R -t "$HOME" "$pkg" 2>&1 || log_warning "Could not stow $pkg (may already exist)"
  done

  log_success "Dotfiles installed"
}

# Change default shell to zsh
change_shell() {
  log_info "Phase 13: Setting zsh as default shell..."

  if [ "$SHELL" = "$(which zsh)" ]; then
    log_warning "zsh is already the default shell"
    return 0
  fi

  log_info "Changing default shell to zsh (requires password)"
  chsh -s "$(which zsh)"

  log_success "Default shell changed to zsh"
}

# Main installation function
main() {
  echo ""
  echo "╔════════════════════════════════════════════════════════════╗"
  echo "║          Dotfiles Installation Script                     ║"
  echo "║  Fresh Linux Installation Setup                            ║"
  echo "╚════════════════════════════════════════════════════════════╝"
  echo ""

  log_info "Starting installation process..."
  echo ""

  # Check if we're in the dotfiles directory
  if [ ! -f "$DOTFILES_DIR/install.sh" ]; then
    log_error "Please run this script from the dotfiles directory"
    exit 1
  fi

  # Run installation phases
  install_system_packages
  install_neovim
  install_homebrew
  install_brew_tools
  install_oh_my_zsh
  install_nvm
  install_go
  install_k8s_tools
  install_nerd_font
  install_tpm
  backup_existing_configs
  stow_dotfiles
  change_shell

  echo ""
  echo "╔════════════════════════════════════════════════════════════╗"
  echo "║          Installation Complete!                            ║"
  echo "╚════════════════════════════════════════════════════════════╝"
  echo ""
  log_success "All components installed successfully!"
  echo ""
  log_info "Next steps:"
  echo "  1. Log out and log back in (or run: exec zsh)"
  echo "  2. Open tmux and press Alt+a followed by I to install tmux plugins"
  echo "  3. Open nvim - plugins will auto-install via lazy.nvim"
  echo "  4. Configure Alacritty to use JetBrainsMono Nerd Font"
  echo "  5. For Kubernetes: Configure kubeconfig and credentials"
  echo ""

  if [ -d "$BACKUP_DIR" ]; then
    log_info "Your old configs were backed up to: $BACKUP_DIR"
  fi

  echo ""
}

# Run main function
main
