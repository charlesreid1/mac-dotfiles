# This is the bash profile.
#
# This file sets PATH and bash options.
#
# to add your own non-committed machine-specific settings,
# use ~/.extra

# SILENCE
export BASH_SILENCE_DEPRECATION_WARNING=1

# Must
EDITOR="vim"
GIT_EDITOR="vim"

# Better man pages
PAGER="most"

# Set $PATH here
PATH="${HOME}/scripts:${PATH}"
PATH="/opt/homebrew/bin:$PATH"
PATH="/opt/homebrew/sbin:${PATH}" # homebrew admin tools
PATH="${HOME}/bin:${PATH}"
PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"

# Tell git not to look for getext.sh
# since pyenv has trouble with that
export GIT_INTERNAL_GETTEXT_TEST_FALLBACKS=1

##################################################
# Natera-specific things

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

##################################################
# goenv installer
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"

# Only enable this if you are using go.
# This will add half a second every time you
# open a new shell.
#eval "$(goenv init -)"

# pyenv installer
# https://github.com/pyenv/pyenv-installer
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

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
