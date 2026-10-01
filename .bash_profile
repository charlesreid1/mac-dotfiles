# This is the bash profile.
#
# This file sets PATH and bash options.
#
# to add your own non-committed machine-specific settings,
# use ~/.extra


#######################################################
# okta-aws-cli for legacy account cli access

export OKTA_AWSCLI_ORG_DOMAIN=natera.okta.com
export OKTA_AWSCLI_OIDC_CLIENT_ID=0oaqmmhpit3hj0xl2297
export OKTA_AWSCLI_OPEN_BROWSER="true"
export OKTA_AWSCLI_WRITE_AWS_CREDENTIALS="true"

# make sure to create ~/.okta/okta.yaml with this:
# ---
# awscli:
#   profiles:
#     natera-ecd-dev:
#       aws-acct-fed-app-id: "0oa1oj1zdvEEV8WPJ297"
#       aws-iam-idp: "arn:aws:iam::169413595963:saml-provider/OktaSSO-TF"
#       aws-iam-role: "arn:aws:iam::169413595963:role/ReadOnly"

export AWS_VAULT_BACKEND=file
export AWS_VAULT_PROMPT=terminal
# AWS_VAULT_FILE_PASSPHRASE lives in ~/.extra (mode 600, sourced below)



###################################
# Natera Netskope
export AWS_CA_BUNDLE=~/.aws/nskp_config/netskope-cert-bundle.pem
export REQUESTS_CA_BUNDLE=~/.aws/nskp_config/netskope-cert-bundle.pem
export SSL_CERT_FILE=~/.aws/nskp_config/netskope-cert-bundle.pem
export NODE_EXTRA_CA_CERTS=~/.aws/nskp_config/netskope-cert-bundle.pem

##################################
# Natera Claude Code
# https://go.confluence.natera.com/wiki/spaces/SRETOOLS/pages/383356332/Claude+Code+Onboarding
export PATH="$HOME/.local/bin:$PATH"
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-west-2
export ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION=us-west-2
export AWS_PROFILE="claude"


# Thinking depth and output length are governed by effortLevel in ~/.claude/settings.json

# # Just pick the one you want through claude code, or set it in ~/.claude/settings.json
# # This way of managing things gets too messy, available bedrock model names are inconsistent, it is a pain
#export ANTHROPIC_MODEL=us.anthropic.claude-sonnet-4-20250514-v1:0
#export ANTHROPIC_MODEL=us.anthropic.claude-opus-4-1-20250805-v1:0
#export ANTHROPIC_MODEL=us.anthropic.claude-sonnet-4-5-20250929-v1:0
#export ANTHROPIC_MODEL=global.anthropic.claude-opus-4-5-20251101-v1:0
#export ANTHROPIC_MODEL=global.anthropic.claude-opus-4-6-v1:0
#export ANTHROPIC_MODEL=global.anthropic.claude-sonnet-5
#export ANTHROPIC_MODEL=global.anthropic.claude-opus-4-8-v1
#export ANTHROPIC_DEFAULT_HAIKU_MODEL=us.anthropic.claude-haiku-4-5-20251001-v1:0

export AWS_VAULT_KEYCHAIN_NAME="login"


###################################
# Natera Synapse

source ~creid/.synapse_api_key


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

# Added by Antigravity
export PATH="/Users/creid/.antigravity/antigravity/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
. "$HOME/.cargo/env"

# Dedupe PATH (first occurrence wins). ~/.bashrc re-sources this file in
# non-login shells, which would otherwise prepend every entry again.
PATH="$(printf '%s' "$PATH" | awk -v RS=: -v ORS=: '!seen[$0]++')"; PATH="${PATH%:}"
export PATH
