export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
zstyle ':omz:update' mode reminder  # just remind me to update when it's time

plugins=(kubectl k9s git z aws fzf colorize web-search zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search history)

# Using emacs mode instead of vi-mode - easier for command editing
# Ctrl+a/e for line start/end, Ctrl+w/u/k for deletion, Ctrl+r for fzf search
 
source $ZSH/oh-my-zsh.sh

# User configuration
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nvim'
else
  export EDITOR='nvim'
fi

if [[ -f "$HOME/.credentials.sh" ]]; then
  source $HOME/.credentials.sh
fi

export PATH="$HOME/.cargo/bin:$HOME/.opencode/bin:$HOME/.local/bin:$PATH"

bindkey '^p' autosuggest-accept

alias vim="nvim"
alias sudov="sudo -E nvim"
alias run-podman="source ~/run_podman.sh"
alias jl="jenkins-lint -u $JENKINS_USERNAME -p $JENKINS_PASSWORD"
alias gp="git fetch --prune && git branch -vv | grep 'gone]' | awk '{print $1}' | xargs git branch -D"
alias vsb="veeamconfig job start --name 'CompleteBackup'"
alias tf-clean="find . -type d -name ".terraform" -prune -exec rm -rf {} \;"
alias tg-clean="find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;"
alias sts='stskeygen refresh --profile packstyle --account "packstyle" --role "AWS-PACKSTYLE"'
alias fd='fdfind'

# alias podman-service="podman system service -t 0 &"
# export HTTP_PROXY="http://172.17.205.1:3128"
# DOCKER_HOST="unix:$XDG_RUNTIME_DIR/podman/podman.sock"

export NVM_DIR="$HOME/.nvm"

nvm() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  nvm "$@"
}

node() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  node "$@"
}

npm() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  npm "$@"
}

npx() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  npx "$@"
}

export PATH=$PATH:/usr/local/go/bin

# AWS CLI completion
autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit


fpath=(/usr/local/share/zsh/site-functions $fpath)

if [ -f /usr/local/bin/aws_completer ]; then
  complete -C '/usr/local/bin/aws_completer' aws
fi

# Talosctl completions
if command -v talosctl &> /dev/null; then
  source <(talosctl completion zsh)
fi

eval "$(zoxide init zsh --cmd cd)"

# tmux-sessionizer

alias ts="~/.local/bin/tmux-sessionizer"

bindkey -s '^f' 'ts\n'

bindkey -s '\e1' "~/.local/bin/tmux-sessionizer -s 0\n"
bindkey -s '\e2' "~/.local/bin/tmux-sessionizer -s 1\n"
bindkey -s '\e3' "~/.local/bin/tmux-sessionizer -s 2\n"

# Quick directory jumps
alias tso="~/.local/bin/tmux-sessionizer ~/omnys/git"
alias tsd="~/.local/bin/tmux-sessionizer ~/.dotfiles"
alias tsp="~/.local/bin/tmux-sessionizer ~/.dotfiles-private"
alias tsc="~/.local/bin/tmux-sessionizer ~/.config"

# FZF
export FZF_DEFAULT_COMMAND="fd --hidden --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND --type d"

# SSH completion already works with fzf via ** trigger:
#   ssh **<TAB>  - shows hosts from ~/.ssh/config and known_hosts

# AWS profile switcher with fzf - usage: awsp
awsp() {
  local profile
  profile=$(aws configure list-profiles 2>/dev/null | fzf --prompt="AWS Profile > ")
  if [[ -n "$profile" ]]; then
    export AWS_PROFILE="$profile"
    echo "Switched to AWS profile: $profile"
  fi
}

# SSH with fzf host selection - usage: sshf
sshf() {
  local host
  host=$(grep -E "^Host " ~/.ssh/config.d/* 2>/dev/null | awk '{print $2}' | grep -v '\*' | fzf --prompt="SSH Host > ")
  if [[ -n "$host" ]]; then
    ssh "$host"
  fi
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Vim-style navigation in emacs mode
bindkey '^[h' backward-char
bindkey '^[l' forward-char
bindkey '^[k' up-line-or-history
bindkey '^[j' down-line-or-history
bindkey '^w' backward-kill-word
bindkey '^k' kill-line
bindkey '^u' backward-kill-line

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
