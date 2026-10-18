#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.config/dotfiles/machine.sh" || exit 1

# An empty target lists every file bootstrap would copy, not just changed files.
# Use the same rsync exclusions as bootstrap and handle paths containing spaces.
EMPTY_DIR=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-preview.XXXXXX") || exit 1
trap 'rmdir "$EMPTY_DIR"' EXIT
FILES=$(rsync -an --exclude-from "$SCRIPT_DIR/bootstrap_exclude.txt" \
    --out-format '%n' "$SCRIPT_DIR/" "$EMPTY_DIR/") || exit 1

preview_file() {
    local installed=$1 proposed=$2 status
    printf '\n------------\n%s\n' "$installed"
    if [ -f "$installed" ]; then
        # Home first: deletions are red, additions are green.
        command git diff --no-index --exit-code -- "$installed" "$proposed"
        status=$?
        if [ "$status" -eq 0 ]; then
            printf 'No differences!\n'
        elif [ "$status" -gt 1 ]; then
            return "$status"
        fi
    else
        printf 'New file:\n'
        command git diff --no-index -- /dev/null "$proposed"
        status=$?
        [ "$status" -le 1 ] || return "$status"
    fi
    return 0
}

printf 'Previewing dotfiles for %s (%s)\n' "$DOTFILES_MACHINE_LABEL" "$DOTFILES_HOSTNAME"
while IFS= read -r file; do
    case "$file" in ''|*/) continue ;; esac
    preview_file "$HOME/$file" "$SCRIPT_DIR/$file" || exit 1
done <<< "$FILES"

# This selected include is installed separately after rsync.
preview_file "$HOME/.gitconfig_machine" \
    "$SCRIPT_DIR/.config/dotfiles/machines/$DOTFILES_MACHINE/gitconfig" || exit 1
