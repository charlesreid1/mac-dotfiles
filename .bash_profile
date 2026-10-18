# This is the bash profile.
#
# This file sets PATH and bash options.
#
# to add your own non-committed machine-specific settings,
# use ~/.extra


# Select the laptop once; all shell settings use the same profile.
source "$HOME/.config/dotfiles/machine.sh" || return

# Must
EDITOR="vim"
GIT_EDITOR="vim"

# Better man pages
PAGER="most"

# Homebrew: prefer each laptop's existing install, with an architecture fallback.
case "$DOTFILES_MACHINE" in
    natty) HOMEBREW_PREFIX=/opt/homebrew ;;
    kraken) HOMEBREW_PREFIX=/usr/local ;;
    *)
        if [ -x /opt/homebrew/bin/brew ]; then
            HOMEBREW_PREFIX=/opt/homebrew
        else
            HOMEBREW_PREFIX=/usr/local
        fi
        ;;
esac
if [ ! -x "$HOMEBREW_PREFIX/bin/brew" ]; then
    if [ -x /opt/homebrew/bin/brew ]; then
        HOMEBREW_PREFIX=/opt/homebrew
    elif [ -x /usr/local/bin/brew ]; then
        HOMEBREW_PREFIX=/usr/local
    fi
fi
if [ -x "$HOMEBREW_PREFIX/bin/brew" ]; then
    eval "$("$HOMEBREW_PREFIX/bin/brew" shellenv)"
fi

# Set common PATH entries after brew shellenv so GNU coreutils remain preferred.
PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"
PATH="$HOME/.local/bin:$HOME/bin:$HOME/scripts:$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"

# pyenv (optional on a freshly bootstrapped machine)
export PYENV_ROOT="$HOME/.pyenv"
PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init --path)"
fi

# Machine-specific environment precedes aliases so local API keys are available.
if [ -r "$HOME/.config/dotfiles/machines/$DOTFILES_MACHINE/profile.sh" ]; then
    source "$HOME/.config/dotfiles/machines/$DOTFILES_MACHINE/profile.sh"
fi

# Preserve the older laptop's optional setup without applying it to either new one.
if [[ "$DOTFILES_HOSTNAME" == "maya" ]]; then

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
    [ ! -r "$HOME/.git-completion.bash" ] || source "$HOME/.git-completion.bash"

    # Enable tab completion for `g` by marking it as an alias for `git`
    if type _git &> /dev/null && [ -f /usr/local/etc/bash_completion.d/git-completion.bash ]; then
        complete -o default -o nospace -F _git g;
    fi;

fi

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

# # nvm
# # This is infuriatingly slow.
# # Takes a full second to get through this, every terminal tab, every terminal window, every time
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# shut up
[ -e "${HOME}/.hushlogin" ] || touch "${HOME}/.hushlogin"
export BASH_SILENCE_DEPRECATION_WARNING=1
export FILTER_BRANCH_SQUELCH_WARNING=1

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ ! -r "$HOME/.cargo/env" ] || source "$HOME/.cargo/env"

# Dedupe PATH (first occurrence wins). ~/.bashrc re-sources this file in
# non-login shells, which would otherwise prepend every entry again.
PATH="$(printf '%s' "$PATH" | awk -v RS=: -v ORS=: '!seen[$0]++')"; PATH="${PATH%:}"
export PATH
