# This is the bash profile.
# 
# This file sets PATH and bash options.
#
# to add your own non-committed machine-specific settings,
# use ~/.extra 

# Must
EDITOR="vim"
GIT_EDITOR="vim"


# Set $PATH here
PATH="/usr/local/bin:$PATH"
PATH="/usr/local/sbin:${PATH}" # homebrew admin tools

if [[ "$HOSTNAME" == "maya" ]]; then

	# Setting PATH for homebrew
	PATH="/Users/charles/.local/bin:$PATH"
	PATH="/Users/charles/Library/Python/3.6/bin:$PATH"

    ### # some weird new homebrew thing??
    ### # this is where python -> python3 lives now
    ### # https://stackoverflow.com/a/45228901
    ### PATH="/usr/local/opt/python/libexec/bin:${PATH}"

	# Set up google cloud SDK
	F1="/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc"
	F2="/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc"
	if [[ -f $F1 ]]; then
		source $F1
	fi
	if [[ -f $F2 ]]; then
		source $F2
	fi

fi

# pyenv installer
# https://github.com/pyenv/pyenv-installer
export PATH="/Users/charles/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
#eval "$(pyenv virtualenv-init -)"


export PATH

# Just let homebrew take care of PYTHONPATH, yeah?
# But if you really needed to, you could set it here.

# Bash history

HISTFILE="$HOME/.bash_history"
HISTFILESIZE=1000000000
HISTIGNORE="ls:cls:clc:clear:pwd:l:ll:[ ]*"
HISTSIZE=1000000
HISTTIMEFORMAT=': %Y-%m-%d_%H:%M:%S; '

# Append to the Bash history file, rather than overwriting it
shopt -s histappend;
# Save Bash history 
shopt -s cmdhist;




#############################
# modified mathias

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
	shopt -s "$option" 2> /dev/null;
done;

if [ -f /etc/bash_completion ]; then
	source /etc/bash_completion;
fi;

# Enable tab completion for `g` by marking it as an alias for `git`
if type _git &> /dev/null && [ -f /usr/local/etc/bash_completion.d/git-completion.bash ]; then
	complete -o default -o nospace -F _git g;
fi;

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

