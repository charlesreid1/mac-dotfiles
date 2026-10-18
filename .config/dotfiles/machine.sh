# Shared machine detection for shell startup, bootstrap, and its diff preview.
# Use the actual hostname, not Bash's potentially stale/inherited HOSTNAME.
DOTFILES_HOSTNAME=$(hostname)
DOTFILES_HOSTNAME=${DOTFILES_HOSTNAME%%.*}

# An explicit override is useful for testing or after renaming a laptop.
if [ -z "${DOTFILES_MACHINE:-}" ]; then
    case "$DOTFILES_HOSTNAME" in
        creid-mac|natty) DOTFILES_MACHINE=natty ;;
        kraken) DOTFILES_MACHINE=kraken ;;
        *) DOTFILES_MACHINE=generic ;;
    esac
fi

case "$DOTFILES_MACHINE" in
    natty|kraken) DOTFILES_MACHINE_LABEL=$DOTFILES_MACHINE ;;
    generic) DOTFILES_MACHINE_LABEL=$DOTFILES_HOSTNAME ;;
    *)
        printf 'Unknown dotfiles machine profile: %s\n' "$DOTFILES_MACHINE" >&2
        return 1
        ;;
esac
