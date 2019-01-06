[ -n "$PS1" ] && source ~/.bash_profile;

# mcfly is a pretty cool command completion program
# Control + R on the command line, then start typing stuff
if [[ -f "$(brew --prefix)/opt/mcfly/mcfly.bash" ]]; then
  source "$(brew --prefix)/opt/mcfly/mcfly.bash"
fi
