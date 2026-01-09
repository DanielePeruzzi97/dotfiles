export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
zstyle ':omz:update' mode reminder  # just remind me to update when it's time

plugins=(kubectl k9s git z aws fzf colorize web-search zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search history vi-mode)

# Vi-mode settings (oh-my-zsh vi-mode plugin)
VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
VI_MODE_SET_CURSOR=true
VI_MODE_CURSOR_NORMAL=2   # Block cursor in normal mode
VI_MODE_CURSOR_VISUAL=2   # Block cursor in visual mode
VI_MODE_CURSOR_INSERT=2   # Block cursor in insert mode
VI_MODE_CURSOR_OPPEND=2   # Block cursor in operator pending mode
export KEYTIMEOUT=15      # Low enough for responsiveness, high enough for key combos
 
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

export PATH=/home/daniele.peruzzi@omnys.lan/.opencode/bin:$PATH
export PATH=/home/daniele.peruzzi@omnys.lan/.local/bin:$PATH

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
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH=$PATH:/usr/local/go/bin

# To load aws cli auto completion
autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit

# Add argcomplete to fpath for proper zsh completion
fpath=(/usr/local/share/zsh/site-functions $fpath)

if [ -f /usr/local/bin/aws_completer ]; then
  complete -C '/usr/local/bin/aws_completer' aws
fi

# Talosctl completions
if command -v talosctl &> /dev/null; then
  source <(talosctl completion zsh)
fi

eval "$(zoxide init zsh --cmd cd)"

# tmux-sessionizer integration - consistent and self-explanatory
# Main aliases
alias ts="~/.local/bin/tmux-sessionizer"

# Keybindings (matching tmux and nvim) - Alt+1/2/3
bindkey -s '\e1' "~/.local/bin/tmux-sessionizer -s 0\n"  # Alt-1: htop
bindkey -s '\e2' "~/.local/bin/tmux-sessionizer -s 1\n"  # Alt-2: lazygit
bindkey -s '\e3' "~/.local/bin/tmux-sessionizer -s 2\n"  # Alt-3: opencode

# Quick directory shortcuts (as aliases for convenience)
alias tso="~/.local/bin/tmux-sessionizer ~/omnys/git"
alias tsd="~/.local/bin/tmux-sessionizer ~/.dotfiles"
alias tsp="~/.local/bin/tmux-sessionizer ~/.dotfiles-private"
alias tsc="~/.local/bin/tmux-sessionizer ~/.config"

# FZF Configuration
# -----------------
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
  host=$(grep -E "^Host " ~/.ssh/config 2>/dev/null | awk '{print $2}' | grep -v '\*' | fzf --prompt="SSH Host > ")
  if [[ -n "$host" ]]; then
    ssh "$host"
  fi
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Keep Ctrl-r for fzf history search in vi mode (both insert and normal)
bindkey -M viins '^r' fzf-history-widget
bindkey -M vicmd '^r' fzf-history-widget

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"


# opencode
export PATH=/home/dperuzzi/.opencode/bin:$PATH
