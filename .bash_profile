# This is the bash profile.
#
# This file sets PATH and bash options.
#
# to add your own non-committed machine-specific settings,
# use ~/.extra


# Must
EDITOR="vim"
GIT_EDITOR="vim"

# Better man pages
PAGER="most"

# Go stuff
GOROOT=$HOME/go
GOPATH=$HOME/go


# Set $PATH here
PATH="${HOME}/scripts:${PATH}"
PATH="/usr/local/bin:$PATH"
PATH="/usr/local/sbin:${PATH}" # homebrew admin tools
PATH="${PATH}:${GOROOT}/bin"
PATH="/usr/local/opt/coreutils/libexec/gnubin:${PATH}"
PATH="${HOME}/bin:${PATH}"

# claude code
export PATH="$HOME/.local/bin:$PATH"
export ANTHROPIC_DEFAULT_OPUS_MODEL="claude-opus-4-6"
export ANTHROPIC_MODEL="claude-opus-4-6"

# gemini
source $HOME/.gemini_api_key

# deepseek
source $HOME/.deepseek_api_key


if [[ "$HOSTNAME" == "maya" ]]; then

	# Setting PATH for homebrew
	PATH="$HOME/Library/Python/3.6/bin:$PATH"

    # pypy
    # this should go after /usr/local/bin
    PATH="${PATH}:/usr/local/share/pypy3"

	# Set up google cloud SDK
	F1="/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc"
	F2="/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc"
	if [[ -f $F1 ]]; then
		source $F1
	fi
	if [[ -f $F2 ]]; then
		source $F2
	fi

    # git tab completion
    source ${HOME}/.git-completion.bash

    # Enable tab completion for `g` by marking it as an alias for `git`
    if type _git &> /dev/null && [ -f /usr/local/etc/bash_completion.d/git-completion.bash ]; then
    	complete -o default -o nospace -F _git g;
    fi;
fi

if [[ "$HOSTNAME" == "kraken" ]]; then

    # homebrew
    eval "$(/usr/local/bin/brew shellenv)"

    ### # node
    ### export NVM_DIR="$HOME/.nvm"
    ### [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    ### [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

    # spicetify
    export PATH=$PATH:/Users/charles/.spicetify
fi

# pyenv
# https://github.com/pyenv/pyenv-installer
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

export PATH

# Just let homebrew take care of PYTHONPATH, yeah?
# But if you really needed to, you could set it here.


# Bash history

HISTFILE="$HOME/.bash_history"
HISTFILESIZE=1000000000
HISTIGNORE="ls:cls:clc:clear:pwd:l:ll:[ ]*"
HISTSIZE=1000000
HISTTIMEFORMAT=': %Y-%m-%d_%H:%M:%S; '

# Save Bash history
shopt -s cmdhist;
# Append to the Bash history file, rather than overwriting it
shopt -s histappend;
# Write history to .bash_history immediately.
# -a writes current/new lines to history file
# -n reloads only new commands
# https://askubuntu.com/a/673283
PROMPT_COMMAND='history -a;history -n'

# don't try to autocomplete commands when tab is pressed and line is empty
shopt -s no_empty_cmd_completion

#############################
# ssh-agent setup
### SSH_ENV="$HOME/.ssh/agent-environment"
###
### function start_agent {
###     /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
###     chmod 600 "${SSH_ENV}"
###     . "${SSH_ENV}" > /dev/null
###     /usr/bin/ssh-add;
### }
###
### # Source SSH settings, if applicable
### if [ -f "${SSH_ENV}" ]; then
###     . "${SSH_ENV}" > /dev/null
###     ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
###         start_agent;
###     }
### else
###     start_agent;
### fi


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

if [ -f /etc/bash_completion ]; then
	source /etc/bash_completion;
fi;

# shut up
touch ${HOME}/.hushlogin
export BASH_SILENCE_DEPRECATION_WARNING=1
export FILTER_BRANCH_SQUELCH_WARNING=1
