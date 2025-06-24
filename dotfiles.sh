#!/usr/bin/env bash

dotfilerepo="${HOME}/.dotfiles"
stowcmd="stow -v -R -t ${HOME}"

usage() {
    echo "Usage: $0 sync [package1 package2 ... | all]"
    exit 1
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

if [[ "$1" == sync ]]; then
    shift
    if [[ "$#" -eq 0 ]]; then
        usage
    else
        sync_dotfiles "$@"
    fi
else
    usage
fi
