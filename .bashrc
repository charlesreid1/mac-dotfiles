# Interactive shells load the profile. natty skips it for non-interactive ssh
# commands (scp); other laptops keep it so mosh can find mosh-server.
source ~/.config/dotfiles/machine.sh
if [ -n "$PS1" ] || [ "$DOTFILES_MACHINE" != natty ]; then
    source ~/.bash_profile
fi
