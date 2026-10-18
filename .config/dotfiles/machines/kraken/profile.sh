# Personal laptop (hostname: kraken).

GOROOT="$HOME/go"
GOPATH="$HOME/go"
PATH="$PATH:$GOROOT/bin"
export ANDROID_HOME="$HOMEBREW_PREFIX/share/android-commandlinetools"

export ANTHROPIC_DEFAULT_OPUS_MODEL="claude-opus-5-5"
export ANTHROPIC_MODEL="claude-opus-5-5"
export CLAUDE_CODE_NO_FLICKER=0
export CLAUDE_CODE_DISABLE_UNKNOWN_MODEL_WINDOW_ENFORCEMENT=1

# Optional local secrets; never committed or required to open a shell.
[ ! -r "$HOME/.gemini_api_key" ] || source "$HOME/.gemini_api_key"
[ ! -r "$HOME/.deepseek_api_key" ] || source "$HOME/.deepseek_api_key"

PATH="$PATH:$HOME/.spicetify"

# Kraken uses the full pyenv shell integration; natty only needs --path.
if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

# Custom ls colors: light blue directories.
export LSCOLORS=Gxfxcxdxbxegedabagacad
