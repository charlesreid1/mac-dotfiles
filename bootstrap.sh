#!/usr/bin/env bash

# Updating the checkout is separate from installing it: run git pull explicitly.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1
source "$SCRIPT_DIR/.config/dotfiles/machine.sh" || exit 1

function doIt() {
    rsync \
        --exclude-from "$SCRIPT_DIR/bootstrap_exclude.txt" \
        -avh --no-perms "$SCRIPT_DIR/" "$HOME/" || return 1

    # Git cannot branch on hostname. Install an include file using the same
    # machine selection as the shell, with no Git mutations during shell startup.
    cp "$SCRIPT_DIR/.config/dotfiles/machines/$DOTFILES_MACHINE/gitconfig" \
        "$HOME/.gitconfig_machine" || return 1
    printf 'Installed dotfiles for %s. Open a new shell or run: exec bash -l\n' "$DOTFILES_MACHINE_LABEL"
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
    doIt || exit 1
else
    bash "$SCRIPT_DIR/diff_dotfiles.sh" || exit 1
    echo "The changes in RED will DISAPPEAR FOREVER FROM YOUR DOTFILES."
    echo "The changes in GREEN will be ADDED TO YOUR DOTFILES."
    read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
    echo "";
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        doIt || exit 1
    fi;
fi;
unset doIt;
