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
      zoxide
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

install_topgrade() {
  log_info "Phase 4.5: Installing Topgrade (universal updater)..."

  if command_exists topgrade; then
    log_warning "Topgrade already installed: $(topgrade --version | head -n1)"
    return 0
  fi

  local distro=$(detect_distro)

  case "$distro" in
  arch | manjaro | cachyos | endeavouros)
    sudo pacman -S --noconfirm topgrade
    ;;
  *)
    if command_exists cargo; then
      cargo install topgrade
    elif command_exists brew; then
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
      brew install topgrade
    else
      log_warning "Installing Topgrade requires cargo or brew. Skipping."
      return 1
    fi
    ;;
  esac

  log_success "Topgrade installed"
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

# Install Ghostty terminal emulator
install_ghostty() {
  log_info "Phase 10.5: Installing Ghostty terminal..."

  if command_exists ghostty; then
    log_warning "Ghostty already installed: $(ghostty --version 2>/dev/null | head -1)"
    return 0
  fi

  local distro=$(detect_distro)

  case "$distro" in
  ubuntu | debian | pop)
    # Use mkasberg/ghostty-ubuntu installer (downloads .deb from GitHub releases)
    log_info "Installing Ghostty via mkasberg/ghostty-ubuntu..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"
    ;;

  fedora | rhel | centos)
    # Fedora may have ghostty in repos or COPR
    if ! sudo dnf install -y ghostty 2>/dev/null; then
      log_warning "Ghostty not found in repos - check COPR or build from source"
    fi
    ;;

  arch | manjaro)
    # Ghostty is in official Arch repos
    sudo pacman -S --noconfirm ghostty
    ;;

  *)
    log_warning "Ghostty installation not configured for $distro"
    log_info "  For Ubuntu/Debian: https://github.com/mkasberg/ghostty-ubuntu"
    log_info "  For Arch: pacman -S ghostty"
    log_info "  For others: https://ghostty.org/docs/install"
    return 1
    ;;
  esac

  if command_exists ghostty; then
    log_success "Ghostty installed: $(ghostty --version 2>/dev/null | head -1)"
    
    # Set as default terminal
    log_info "Setting Ghostty as default terminal..."
    sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/ghostty 50 2>/dev/null || true
    sudo update-alternatives --set x-terminal-emulator /usr/bin/ghostty 2>/dev/null || true
  else
    log_error "Ghostty installation failed"
  fi
}

# Install Hyprland desktop environment packages
install_hyprland_packages() {
  log_info "Phase 11: Installing Hyprland desktop environment packages..."

  local distro=$(detect_distro)

  # Unified package list for all distros:
  # Core: waybar, swaync, rofi, hyprlock, hypridle, hyprpaper
  # Extras: swayosd, wlogout, cliphist, grim, slurp
  # Utils: brightnessctl, playerctl, udiskie, wl-clipboard
  # File manager: nautilus (GTK, visually appealing)
  # System: xdg-user-dirs, xdg-desktop-portal-gtk, gvfs, tumbler
  # Monitor: btop

  case "$distro" in
  ubuntu | debian | pop)
    log_info "Installing Hyprland packages for Ubuntu/Debian..."
    sudo apt install -y \
      waybar \
      sway-notification-center \
      rofi \
      swayosd \
      wlogout \
      cliphist \
      wl-clipboard \
      brightnessctl \
      playerctl \
      udiskie \
      polkit-kde-agent-1 \
      network-manager-gnome \
      blueman \
      pavucontrol \
      grim \
      slurp \
      hyprsunset \
      nautilus \
      qt5ct \
      qt6ct \
      xdg-user-dirs \
      xdg-desktop-portal-gtk \
      gvfs \
      tumbler \
      btop \
      rofi-calc

    # hyprlock, hypridle, hyprpaper may need PPA on Ubuntu
    sudo apt install -y hyprlock hypridle hyprpaper grimblast 2>/dev/null || \
      log_warning "hyprlock/hypridle/hyprpaper not found - add Hyprland PPA: sudo add-apt-repository ppa:hyprwm/hyprland"
    ;;

  fedora | rhel | centos)
    log_info "Installing Hyprland packages for Fedora..."
    sudo dnf install -y \
      waybar \
      SwayNotificationCenter \
      rofi-wayland \
      swayosd \
      wlogout \
      cliphist \
      wl-clipboard \
      brightnessctl \
      playerctl \
      udiskie \
      polkit-kde \
      network-manager-applet \
      blueman \
      pavucontrol \
      grim \
      slurp \
      hyprlock \
      hypridle \
      hyprpaper \
      hyprsunset \
      nautilus \
      qt5ct \
      qt6ct \
      xdg-user-dirs \
      xdg-desktop-portal-gtk \
      gvfs \
      tumbler \
      btop

    # grimblast for Fedora (may need COPR)
    sudo dnf install -y grimblast 2>/dev/null || \
      log_warning "grimblast not found - install manually"
    ;;

  arch | manjaro)
    log_info "Installing Hyprland packages for Arch..."
    sudo pacman -Sy --noconfirm \
      waybar \
      rofi-wayland \
      wlogout \
      cliphist \
      wl-clipboard \
      brightnessctl \
      playerctl \
      udiskie \
      polkit-kde-agent \
      network-manager-applet \
      blueman \
      pavucontrol \
      grim \
      slurp \
      hyprlock \
      hypridle \
      hyprpaper \
      hyprsunset \
      nautilus \
      qt5ct \
      qt6ct \
      xdg-user-dirs \
      xdg-desktop-portal-gtk \
      gvfs \
      tumbler \
      btop

    # Install from AUR (swaync, swayosd, grimblast)
    if command_exists yay; then
      yay -S --noconfirm swaync swayosd-git grimblast-git hyprshot rofi-calc
    elif command_exists paru; then
      paru -S --noconfirm swaync swayosd-git grimblast-git hyprshot rofi-calc
    else
      log_warning "No AUR helper found, skipping AUR packages (swaync, swayosd, grimblast, rofi addons)"
    fi
    ;;

  *)
    log_warning "Hyprland packages not configured for $distro"
    log_warning "Please install manually: waybar swaync rofi swayosd wlogout cliphist"
    return 1
    ;;
  esac

  log_success "Hyprland packages installed"
}

# Install Hyprland plugins
install_hyprland_plugins() {
  log_info "Phase 12: Installing Hyprland plugins..."

  if ! command_exists hyprpm; then
    log_warning "hyprpm not found - skipping Hyprland plugin installation"
    return 0
  fi

  # Update hyprpm
  hyprpm update

  # Install hyprsplit (workspaces per monitor)
  if ! hyprpm list | grep -q "hyprsplit.*enabled: true"; then
    log_info "Installing hyprsplit plugin..."
    hyprpm add https://github.com/shezdy/hyprsplit
    hyprpm enable hyprsplit
    log_success "hyprsplit installed"
  else
    log_warning "hyprsplit already installed"
  fi

  log_success "Hyprland plugins installed"
}

# Install HyprDynamicMonitors for automatic monitor configuration
install_hyprdynamicmonitors() {
  log_info "Phase 12.1: Installing HyprDynamicMonitors..."

  if command_exists hyprdynamicmonitors; then
    log_warning "hyprdynamicmonitors already installed: $(hyprdynamicmonitors --version 2>/dev/null | head -1 || echo 'version check failed')"
    return 0
  fi

  local distro=$(detect_distro)

  # Try to install via package manager first
  case "$distro" in
  ubuntu | debian | pop)
    # Check if available in repos, otherwise install from GitHub
    if ! sudo apt install -y hyprdynamicmonitors 2>/dev/null; then
      log_info "Package not found in repos, installing from GitHub..."
      install_hyprdynamicmonitors_from_github
    fi
    ;;
  
  fedora | rhel | centos)
    # Check if available in repos, otherwise install from GitHub  
    if ! sudo dnf install -y hyprdynamicmonitors 2>/dev/null; then
      log_info "Package not found in repos, installing from GitHub..."
      install_hyprdynamicmonitors_from_github
    fi
    ;;
    
  arch | manjaro)
    # Install from AUR
    if command_exists yay; then
      yay -S --noconfirm hyprdynamicmonitors
    elif command_exists paru; then
      paru -S --noconfirm hyprdynamicmonitors  
    else
      log_warning "No AUR helper found, installing from GitHub..."
      install_hyprdynamicmonitors_from_github
    fi
    ;;
    
  *)
    log_info "Unknown distro, installing from GitHub..."
    install_hyprdynamicmonitors_from_github
    ;;
  esac

  if command_exists hyprdynamicmonitors; then
    log_success "hyprdynamicmonitors installed successfully"
  else
    log_error "Failed to install hyprdynamicmonitors"
  fi
}

# Install HyprDynamicMonitors from GitHub releases
install_hyprdynamicmonitors_from_github() {
  log_info "Installing hyprdynamicmonitors from GitHub releases..."
  
  local LATEST_RELEASE=$(curl -s https://api.github.com/repos/fiffeek/hyprdynamicmonitors/releases/latest | grep tag_name | cut -d '"' -f 4)
  local DOWNLOAD_URL="https://github.com/fiffeek/hyprdynamicmonitors/releases/download/${LATEST_RELEASE}/hyprdynamicmonitors-${LATEST_RELEASE}-linux-amd64.tar.gz"
  
  wget "$DOWNLOAD_URL" -O /tmp/hyprdynamicmonitors.tar.gz
  tar -xzf /tmp/hyprdynamicmonitors.tar.gz -C /tmp
  chmod +x /tmp/hyprdynamicmonitors
  sudo mv /tmp/hyprdynamicmonitors /usr/local/bin/
  rm -f /tmp/hyprdynamicmonitors.tar.gz
  
  log_success "hyprdynamicmonitors ${LATEST_RELEASE} installed from GitHub"
}

# Install desktop applications (utilities, viewers)
install_desktop_apps() {
  log_info "Phase 12.5: Installing desktop applications..."

  local distro=$(detect_distro)

  # Optimized apps for DevOps/SysOps productivity on Wayland:
  # Browser: Firefox (excellent Wayland support, dev tools)
  # PDF: Evince (better GNOME/Wayland integration than Okular)  
  # Image: Loupe (modern GNOME app)
  # Text: GNOME Text Editor (fast, Wayland-native)
  # Archive: File-roller (GTK, matches Nautilus)
  # Media: MPV (lightweight, universal)
  # Phone: KDEConnect (cross-platform)
  # Security: Seahorse (GNOME keyring integration)
  # AWS: AWS CLI + session manager
  # System: Firmware updates, package management

  case "$distro" in
  ubuntu | debian | pop)
    log_info "Installing desktop apps for Ubuntu/Debian..."
    sudo apt install -y \
      firefox \
      evince \
      loupe \
      gnome-text-editor \
      file-roller \
      kdeconnect \
      seahorse \
      mpv \
      gnome-firmware \
      flatpak \
      awscli \
      curl \
      jq \
      tree \
      btop \
      iotop \
      nethogs

    # Add Flathub if not already added
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    ;;

  fedora | rhel | centos)
    log_info "Installing desktop apps for Fedora..."
    sudo dnf install -y \
      firefox \
      evince \
      loupe \
      gnome-text-editor \
      file-roller \
      kdeconnect \
      seahorse \
      mpv \
      gnome-firmware \
      flatpak \
      awscli2 \
      curl \
      jq \
      tree \
      btop \
      iotop \
      nethogs

    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    ;;

  arch | manjaro)
    log_info "Installing desktop apps for Arch..."
    sudo pacman -Sy --noconfirm \
      firefox \
      evince \
      loupe \
      gnome-text-editor \
      file-roller \
      kdeconnect \
      seahorse \
      mpv \
      flatpak \
      aws-cli \
      curl \
      jq \
      tree \
      btop \
      iotop \
      nethogs \
      reflector \
      pkgfile \
      pacman-contrib

    # Arch-specific tools and AUR packages
    if command_exists yay; then
      yay -S --noconfirm gnome-firmware session-manager-plugin rate-mirrors paru
    elif command_exists paru; then
      paru -S --noconfirm gnome-firmware session-manager-plugin rate-mirrors
    else
      log_warning "No AUR helper found - install yay or paru for additional packages"
    fi

    sudo pkgfile --update 2>/dev/null || log_warning "pkgfile database update failed"

    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    ;;

  *)
    log_warning "Desktop apps not configured for $distro"
    ;;
  esac

  log_success "Desktop applications installed"
}

# Install Flatpak applications (cross-platform)
install_flatpak_apps() {
  log_info "Phase 12.6: Installing Flatpak applications..."

  if ! command_exists flatpak; then
    log_warning "Flatpak not installed, skipping Flatpak apps"
    return 0
  fi

  # Core apps - install from Flatpak for cross-platform consistency
  log_info "Installing Flatpak apps (Spotify, Discord, Obsidian, Bitwarden, DBeaver)..."
  
  flatpak install -y --noninteractive flathub com.spotify.Client || log_warning "Spotify install failed"
  flatpak install -y --noninteractive flathub com.discordapp.Discord || log_warning "Discord install failed"
  flatpak install -y --noninteractive flathub md.obsidian.Obsidian || log_warning "Obsidian install failed"
  flatpak install -y --noninteractive flathub com.bitwarden.desktop || log_warning "Bitwarden install failed"
  flatpak install -y --noninteractive flathub io.dbeaver.DBeaverCommunity || log_warning "DBeaver install failed"
  flatpak install -y --noninteractive flathub org.gimp.GIMP || log_warning "GIMP install failed"
  flatpak install -y --noninteractive flathub com.jgraph.drawio.desktop || log_warning "DrawIO install failed"
  
  # Optional: bauh for GUI package management
  # flatpak install -y --noninteractive flathub io.github.AdaltoJunior.Bauh || log_warning "bauh install failed"

  log_success "Flatpak applications installed"
}

# Backup existing dotfiles
backup_existing_configs() {
  log_info "Phase 13: Backing up existing configurations..."

  local files_to_backup=(
    ".zshrc"
    ".tmux.conf"
    ".config/nvim"
    ".config/alacritty"
    ".config/hypr"
    ".config/waybar"
    ".config/mako"
    ".config/swaync"
    ".config/rofi"
    ".config/wlogout"
    ".config/swayosd"
    ".config/hyprdynamicmonitors"
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
  log_info "Phase 14: Installing dotfiles with stow..."

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

# Setup additional dotfile symlinks not handled by stow
setup_additional_symlinks() {
  log_info "Phase 14.2: Setting up additional symlinks..."
  
  # Ensure rofi scripts directory exists and is properly symlinked
  if [ -f "$HOME/.dotfiles/hyprland/.config/rofi/scripts/cliphist.sh" ]; then
    mkdir -p "$HOME/.config/rofi/scripts"
    ln -sf "$HOME/.dotfiles/hyprland/.config/rofi/scripts/cliphist.sh" "$HOME/.config/rofi/scripts/cliphist.sh"
    log_success "Rofi scripts symlinked"
  fi
  
  # Ensure local bin directory exists and symlink bin scripts
  if [ -d "$HOME/.dotfiles/bin" ]; then
    mkdir -p "$HOME/.local/bin"
    for script in "$HOME/.dotfiles/bin"/*; do
      if [ -f "$script" ]; then
        script_name=$(basename "$script")
        ln -sf "$script" "$HOME/.local/bin/$script_name"
        chmod +x "$script"
        log_success "Bin script $script_name symlinked"
      fi
    done
  fi
}

# Setup HyprDynamicMonitors systemd service
setup_hyprdynamicmonitors_service() {
  log_info "Phase 14.1: Setting up HyprDynamicMonitors systemd service..."

  local SERVICE_SOURCE="$HOME/.config/hyprdynamicmonitors/hyprdynamicmonitors.service"
  local SERVICE_DEST="/etc/systemd/user/hyprdynamicmonitors.service"

  # Copy the service file to system-wide user units directory
  if [ -f "$SERVICE_SOURCE" ]; then
    log_info "Installing systemd service to $SERVICE_DEST..."
    sudo cp "$SERVICE_SOURCE" "$SERVICE_DEST"
    sudo chmod 644 "$SERVICE_DEST"
    log_info "Systemd service file installed"
    
    # Reload systemd and enable the service for the current user
    systemctl --user daemon-reload
    systemctl --user enable hyprdynamicmonitors.service
    log_success "HyprDynamicMonitors systemd service enabled"
  else
    log_warning "HyprDynamicMonitors service file not found at $SERVICE_SOURCE, skipping systemd setup"
  fi
}

# Change default shell to zsh
change_shell() {
  log_info "Phase 15: Setting zsh as default shell..."

  if [ "$SHELL" = "$(which zsh)" ]; then
    log_warning "zsh is already the default shell"
    return 0
  fi

  log_info "Changing default shell to zsh (requires password)"
  chsh -s "$(which zsh)"

  log_success "Default shell changed to zsh"
}

# Remove snap and migrate to flatpak
remove_snap_migrate_flatpak() {
  log_info "Phase 16: Removing Snap and migrating to Flatpak..."

  local distro=$(detect_distro)

  # Only proceed on Ubuntu/Debian systems where snap is commonly installed
  case "$distro" in
  ubuntu | debian | pop)
    # Check if snap is installed
    if ! command_exists snap; then
      log_info "Snap not installed, skipping removal"
      return 0
    fi

    log_info "Found snap installation, proceeding with removal and migration..."

    # List installed snaps for migration reference
    local installed_snaps=$(snap list --unicode=never | tail -n +2 | awk '{print $1}' | grep -v "^core" | grep -v "^snapd" | grep -v "^base" | grep -v "^kernel")
    
    if [ -n "$installed_snaps" ]; then
      log_info "Installed snap packages found:"
      echo "$installed_snaps" | while read -r snap_pkg; do
        echo "  - $snap_pkg"
      done

      # Common snap to flatpak migrations
      echo "$installed_snaps" | while read -r snap_pkg; do
        case "$snap_pkg" in
          "discord")
            log_info "Migrating Discord from snap to flatpak..."
            flatpak install -y flathub com.discordapp.Discord || log_warning "Failed to install Discord flatpak"
            ;;
          "code")
            log_info "Migrating VS Code from snap to flatpak..."
            flatpak install -y flathub com.visualstudio.code || log_warning "Failed to install VS Code flatpak"
            ;;
          "firefox")
            log_info "Firefox already available as native package"
            ;;
          "chromium")
            log_info "Migrating Chromium from snap to flatpak..."
            flatpak install -y flathub org.chromium.Chromium || log_warning "Failed to install Chromium flatpak"
            ;;
          "telegram-desktop")
            log_info "Migrating Telegram from snap to flatpak..."
            flatpak install -y flathub org.telegram.desktop || log_warning "Failed to install Telegram flatpak"
            ;;
          "slack")
            log_info "Migrating Slack from snap to flatpak..."
            flatpak install -y flathub com.slack.Slack || log_warning "Failed to install Slack flatpak"
            ;;
          "spotify")
            log_info "Migrating Spotify from snap to flatpak..."
            flatpak install -y flathub com.spotify.Client || log_warning "Failed to install Spotify flatpak"
            ;;
          "thunderbird")
            log_info "Migrating Thunderbird from snap to flatpak..."
            flatpak install -y flathub org.mozilla.Thunderbird || log_warning "Failed to install Thunderbird flatpak"
            ;;
          "libreoffice")
            log_info "Migrating LibreOffice from snap to flatpak..."
            flatpak install -y flathub org.libreoffice.LibreOffice || log_warning "Failed to install LibreOffice flatpak"
            ;;
          "gimp")
            log_info "Migrating GIMP from snap to flatpak..."
            flatpak install -y flathub org.gimp.GIMP || log_warning "Failed to install GIMP flatpak"
            ;;
          "inkscape")
            log_info "Migrating Inkscape from snap to flatpak..."
            flatpak install -y flathub org.inkscape.Inkscape || log_warning "Failed to install Inkscape flatpak"
            ;;
          "blender")
            log_info "Migrating Blender from snap to flatpak..."
            flatpak install -y flathub org.blender.Blender || log_warning "Failed to install Blender flatpak"
            ;;
          "obs-studio")
            log_info "Migrating OBS Studio from snap to flatpak..."
            flatpak install -y flathub com.obsproject.Studio || log_warning "Failed to install OBS Studio flatpak"
            ;;
          "signal-desktop")
            log_info "Migrating Signal from snap to flatpak..."
            flatpak install -y flathub org.signal.Signal || log_warning "Failed to install Signal flatpak"
            ;;
          "whatsapp-for-linux")
            log_info "Migrating WhatsApp from snap to flatpak..."
            flatpak install -y flathub io.github.mimbrero.WhatsAppDesktop || log_warning "Failed to install WhatsApp flatpak"
            ;;
          "teams-for-linux")
            log_info "Migrating Teams from snap to flatpak..."
            flatpak install -y flathub com.github.IsmaelMartinez.teams_for_linux || log_warning "Failed to install Teams flatpak"
            ;;
          "postman")
            log_info "Migrating Postman from snap to flatpak..."
            flatpak install -y flathub com.getpostman.Postman || log_warning "Failed to install Postman flatpak"
            ;;
          "insomnia")
            log_info "Migrating Insomnia from snap to flatpak..."
            flatpak install -y flathub rest.insomnia.Insomnia || log_warning "Failed to install Insomnia flatpak"
            ;;
          "dbeaver-ce")
            log_info "Migrating DBeaver from snap to flatpak..."
            flatpak install -y flathub io.dbeaver.DBeaverCommunity || log_warning "Failed to install DBeaver flatpak"
            ;;
          "bitwarden")
            log_info "Migrating Bitwarden from snap to flatpak..."
            flatpak install -y flathub com.bitwarden.desktop || log_warning "Failed to install Bitwarden flatpak"
            ;;
          "1password")
            log_info "Migrating 1Password from snap to flatpak..."
            flatpak install -y flathub com.1password.1Password || log_warning "Failed to install 1Password flatpak"
            ;;
          "notion-snap")
            log_info "Migrating Notion from snap to flatpak..."
            flatpak install -y flathub notion.notion || log_warning "Failed to install Notion flatpak"
            ;;
          "authy")
            log_info "Migrating Authy from snap to flatpak..."
            flatpak install -y flathub com.authy.Authy || log_warning "Failed to install Authy flatpak"
            ;;
          "flameshot")
            log_info "Migrating Flameshot from snap to flatpak..."
            flatpak install -y flathub org.flameshot.Flameshot || log_warning "Failed to install Flameshot flatpak"
            ;;
          "vlc")
            log_info "Skipping VLC migration - MPV already installed and preferred"
            ;;
          "skype")
            log_info "Migrating Skype from snap to flatpak..."
            flatpak install -y flathub com.skype.Client || log_warning "Failed to install Skype flatpak"
            ;;
          "discord-canary")
            log_info "Migrating Discord Canary from snap to flatpak..."
            flatpak install -y flathub com.discordapp.DiscordCanary || log_warning "Failed to install Discord Canary flatpak"
            ;;
          "firefox-esr")
            log_info "Firefox ESR already available as native package"
            ;;
          "notepadqq")
            log_info "Migrating Notepadqq from snap to flatpak..."
            flatpak install -y flathub com.notepadqq.Notepadqq || log_warning "Failed to install Notepadqq flatpak"
            ;;
          "helm")
            log_info "Helm already available as native package or binary installation preferred for DevOps tools"
            ;;
          "kubectl")
            log_info "kubectl already available as native package or binary installation preferred for DevOps tools"
            ;;
          *)
            log_warning "No automatic migration available for: $snap_pkg"
            log_info "  Check flathub.org for flatpak alternative"
            ;;
        esac
      done

      log_warning "Please verify flatpak alternatives are working before completing removal"
      log_info "Press Enter to continue with snap removal or Ctrl+C to cancel..."
      read -r
    fi

    # Remove snap packages
    log_info "Removing snap packages..."
    echo "$installed_snaps" | while read -r snap_pkg; do
      sudo snap remove "$snap_pkg" || log_warning "Failed to remove snap: $snap_pkg"
    done

    # Remove snap itself
    log_info "Removing snapd..."
    sudo snap remove core20 2>/dev/null || true
    sudo snap remove core22 2>/dev/null || true
    sudo snap remove core 2>/dev/null || true
    sudo snap remove snapd 2>/dev/null || true
    
    sudo apt purge -y snapd
    sudo apt autoremove -y

    # Remove snap directories
    sudo rm -rf /snap /var/snap /var/lib/snapd /var/cache/snapd
    rm -rf ~/snap

    # Prevent snap reinstallation
    echo 'Package: snapd' | sudo tee /etc/apt/preferences.d/no-snapd
    echo 'Pin: release a=*' | sudo tee -a /etc/apt/preferences.d/no-snapd
    echo 'Pin-Priority: -10' | sudo tee -a /etc/apt/preferences.d/no-snapd

    log_success "Snap removed and migrated to Flatpak"
    ;;
    
  *)
    log_info "Snap removal only supported on Ubuntu/Debian systems"
    ;;
  esac
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
  install_topgrade
  install_oh_my_zsh
  install_nvm
  install_go
  install_k8s_tools
  install_nerd_font
  install_tpm
  install_ghostty
  install_hyprland_packages
  install_hyprland_plugins
  install_hyprdynamicmonitors
  install_desktop_apps
  install_flatpak_apps
  backup_existing_configs
  stow_dotfiles
  setup_additional_symlinks
  setup_hyprdynamicmonitors_service
  change_shell
  remove_snap_migrate_flatpak

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
  echo "  4. Configure your terminal to use JetBrainsMono Nerd Font"
  echo "  5. For Kubernetes: Configure kubeconfig and credentials"
  echo "  6. For Hyprland: Log into Hyprland session and run 'hyprpm reload'"
  echo "  7. HyprDynamicMonitors: Service auto-starts with Hyprland for dynamic monitor management"
  echo "  8. Restart swaync/waybar: pkill swaync; swaync & pkill waybar && waybar &"
  echo "  9. Update Flatpak apps: flatpak update"
  echo "  10. Snap has been removed and apps migrated to Flatpak (Ubuntu/Debian only)"
  echo ""

  if [ -d "$BACKUP_DIR" ]; then
    log_info "Your old configs were backed up to: $BACKUP_DIR"
  fi

  echo ""
}

# Run main function
main
