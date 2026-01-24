#!/usr/bin/env bash

dotfilerepo="${HOME}/.dotfiles"
stowcmd="stow -v -R -t ${HOME}"

usage() {
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  install              Run the full installation setup for a fresh system"
    echo "  sync [packages]      Sync dotfiles using stow"
    echo "                       - Use 'all' to sync all packages"
    echo "                       - Or specify individual packages: nvim tmux zshrc"
    echo ""
    echo "Examples:"
    echo "  $0 install           # Install all dependencies and setup dotfiles"
    echo "  $0 sync all          # Sync all dotfiles"
    echo "  $0 sync nvim tmux    # Sync only nvim and tmux configs"
    exit 1
}

install_system() {
    cd "$dotfilerepo" || {
        echo "Error: Could not cd into $dotfilerepo"
        exit 1
    }
    
    if [[ ! -f "$dotfilerepo/install.sh" ]]; then
        echo "Error: install.sh not found in $dotfilerepo"
        exit 1
    fi
    
    bash "$dotfilerepo/install.sh"
}

sync_dotfiles() {
    cd "$dotfilerepo" || {
        echo "Error: Could not cd into $dotfilerepo"
        exit 1
    }

    if [[ "$1" == "all" ]]; then
        for dir in */; do
            $stowcmd "${dir%/}"
        done
    else
        for pkg in "$@"; do
            if [[ -d "${pkg}" ]]; then
                $stowcmd "${pkg}"
            else
                echo "Warning: ${pkg} not found in ${dotfilerepo}"
            fi
        done
    fi
}

case "$1" in
    install)
        install_system
        ;;
    sync)
        shift
        if [[ "$#" -eq 0 ]]; then
            usage
        else
            sync_dotfiles "$@"
        fi
        ;;
    *)
        usage
        ;;
esac
