export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
zstyle ':omz:update' mode reminder  # just remind me to update when it's time

plugins=(git z aws fzf colorize web-search zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search history)
 
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

bindkey '^p' autosuggest-accept

alias vim="nvim"
alias sudov="sudo -E nvim"
alias set-proxy="git config --global http.proxy http://172.17.205.1:3128"
alias unset-proxy="git config --global --unset http.proxy"
alias run-podman="source ~/run_podman.sh"
alias jl="jenkins-lint -u $JENKINS_USERNAME -p $JENKINS_PASSWORD"
alias gp="git fetch --prune && git branch -vv | grep 'gone]' | awk '{print $1}' | xargs git branch -D"
alias vsb="veeamconfig job start --name 'CompleteBackup'"
alias aws-test="aws --profile omnys-test-daniele"
alias tf-clean="find . -type d -name ".terraform" -prune -exec rm -rf {} \;"
alias tg-clean="find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;"
alias sts='stskeygen refresh --profile packstyle --account "packstyle" --role "AWS-PACKSTYLE"'
alias fd='fdfind'
alias eza='eza -1l'

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
if [ -f /usr/local/bin/aws_completer ]; then
  complete -C '/usr/local/bin/aws_completer' aws
fi

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

eval "$(zoxide init zsh --cmd cd)"

export FZF_DEFAULT_COMMAND="fd --hidden"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND --type d"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

export FPATH="$HOME/.config/eza/completions/zsh:$FPATH"

# opencode
export PATH=/home/daniele.peruzzi@omnys.lan/.opencode/bin:$PATH
