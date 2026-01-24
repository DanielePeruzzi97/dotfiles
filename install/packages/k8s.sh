#!/usr/bin/env bash
set -e

log_info "Installing Kubernetes tools..."

if ! command_exists kubectl; then
  KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
  curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
  log_success "kubectl ${KUBECTL_VERSION} installed"
else
  log_warning "kubectl already installed"
fi

if ! command_exists helm; then
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  log_success "Helm installed"
else
  log_warning "Helm already installed"
fi

if ! command_exists talosctl; then
  curl -sL https://talos.dev/install | sh
  log_success "Talosctl installed"
else
  log_warning "Talosctl already installed"
fi

if ! command_exists k9s; then
  if command_exists brew; then
    brew install derailed/k9s/k9s
    log_success "k9s installed"
  else
    log_warning "Homebrew not found, skipping k9s"
  fi
else
  log_warning "k9s already installed"
fi

if ! command_exists kubeseal; then
  KUBESEAL_VERSION=$(curl -s https://api.github.com/repos/bitnami-labs/sealed-secrets/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')
  wget "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz" -O /tmp/kubeseal.tar.gz
  tar -xzf /tmp/kubeseal.tar.gz -C /tmp kubeseal
  chmod +x /tmp/kubeseal
  sudo mv /tmp/kubeseal /usr/local/bin/
  rm /tmp/kubeseal.tar.gz
  log_success "kubeseal installed"
else
  log_warning "kubeseal already installed"
fi

if ! command_exists sops; then
  SOPS_VERSION=$(curl -s https://api.github.com/repos/getsops/sops/releases/latest | grep tag_name | cut -d '"' -f 4)
  wget "https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.amd64" -O /tmp/sops
  chmod +x /tmp/sops
  sudo mv /tmp/sops /usr/local/bin/
  log_success "SOPS installed"
else
  log_warning "SOPS already installed"
fi

if ! command_exists age; then
  AGE_VERSION=$(curl -s https://api.github.com/repos/FiloSottile/age/releases/latest | grep tag_name | cut -d '"' -f 4)
  wget "https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/age-${AGE_VERSION}-linux-amd64.tar.gz" -O /tmp/age.tar.gz
  tar -xzf /tmp/age.tar.gz -C /tmp
  chmod +x /tmp/age/age /tmp/age/age-keygen
  sudo mv /tmp/age/age /tmp/age/age-keygen /usr/local/bin/
  rm -rf /tmp/age.tar.gz /tmp/age
  log_success "age installed"
else
  log_warning "age already installed"
fi

log_success "Kubernetes tools installation complete"
