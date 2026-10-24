#!/usr/bin/env bash

# Updating the checkout is separate from installing it: run git pull explicitly.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1
source "$SCRIPT_DIR/.config/dotfiles/machine.sh" || exit 1

function doIt() {
    rsync \
        --exclude-from "$SCRIPT_DIR/bootstrap_exclude.txt" \
        -avh --no-perms "$SCRIPT_DIR/" "$HOME/" || return 1

    # Files that differ per laptop (Git identities, SSH keys) come from the
    # selected machine's home/ overlay. No --exclude-from: its .gitconfig_machine
    # line would block the overlay's copy.
    rsync -avh --no-perms \
        "$SCRIPT_DIR/.config/dotfiles/machines/$DOTFILES_MACHINE/home/" "$HOME/" || return 1

    # cmux before 0.64.0 silently ignores ~/.config/cmux/cmux.json.
    local cmux_version cmux_major cmux_minor
    cmux_version=$(defaults read /Applications/cmux.app/Contents/Info.plist CFBundleShortVersionString 2>/dev/null)
    IFS=. read -r cmux_major cmux_minor _ <<< "$cmux_version"
    if [ -n "$cmux_version" ] && [ "$cmux_major" -eq 0 ] && [ "$cmux_minor" -lt 64 ] 2>/dev/null; then
        printf 'WARNING: cmux %s ignores ~/.config/cmux/cmux.json (needs 0.64.0+). Update: cmux menu > Check for Updates, or\n  open https://github.com/manaflow-ai/cmux/releases/latest/download/cmux-macos.dmg\n' "$cmux_version"
    fi
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
