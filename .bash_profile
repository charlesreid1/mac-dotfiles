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
PATH="$HOME/pkg/terraform:${PATH}"

if [[ "$HOSTNAME" == "seawater" ]]; then
    # Begin Elasticsearch crap
    #
    # To install elasticsearch 5.4.2 (or whichever version) manually:
    # - install Java (preferably using brew)
    # - download elasticsearch 5.4.2 from here: https://www.elastic.co/downloads/past-releases/elasticsearch-5-4-2
    #   any other version of elasticsearch x.y.z is available at https://www.elastic.co/downloads/past-releases/elasticsearch-x-y-z
    # - extract elasticsearch
    # - set ES_HOME to the directory where you extracted elasticsearch 5.4.2
    # - set JAVA_HOME to the directory where your Java binary lives
    # - set PATH to include both of these directories at the front of the path
    export ES_HOME="${HOME}/pkg/elasticsearch-5.4.2"
    export JAVA_HOME="/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home"
    if [[ -d "$ES_HOME" ]]; then
        export PATH="${ES_HOME}/bin:${JAVA_HOME}/bin:${PATH}"
    fi
    # 
    # End Elasticsearch crap
fi

if [[ "$HOSTNAME" == "maya" ]]; then

	# Setting PATH for homebrew
	PATH="$HOME/.local/bin:$PATH"
	PATH="$HOME/Library/Python/3.6/bin:$PATH"

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



# aws cli tab-completion
# https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-completion.html
complete -C "$(pyenv which aws_completer)" aws



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

# Enable tab completion for `g` by marking it as an alias for `git`
if type _git &> /dev/null && [ -f /usr/local/etc/bash_completion.d/git-completion.bash ]; then
	complete -o default -o nospace -F _git g;
fi;
