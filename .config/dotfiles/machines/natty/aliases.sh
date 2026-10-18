# Corporate AI tools (formerly on natera).
alias aws-claude="echo 'use claude-aws' && ANTHROPIC_MODEL='us.anthropic.claude-opus-5-5[1m]' aws-vault exec claude -- claude"

# New sessions use Opus 5.5; --resume/--continue reuse the transcript's model.
unalias claude 2>/dev/null
_claude_session_model() {
    local f m
    if [ -n "$1" ]; then
        for f in ~/.claude/projects/*/"$1".jsonl; do break; done
    else
        f=$(command ls -t ~/.claude/projects/"$(printf '%s' "$PWD" | sed 's/[^a-zA-Z0-9]/-/g')"/*.jsonl 2>/dev/null | head -1)
    fi
    [ -f "$f" ] || return 1
    m=$(jq -r 'select(.type=="assistant") | .message.model // empty' "$f" 2>/dev/null | command grep -v '^<' | tail -1)
    case "$m" in
        us.*|global.*|eu.*|apac.*|arn:*) ;;
        claude-opus-5-5)   m="us.anthropic.claude-opus-5-5[1m]" ;;
        claude-fable-5-1)  m="global.anthropic.claude-fable-5-1" ;;
        claude-sonnet-4-6) m="global.anthropic.claude-sonnet-4-6" ;;
        claude-*)          m="us.anthropic.$m" ;;
        *) return 1 ;;
    esac
    printf '%s\n' "$m"
}
claude() {
    local model="us.anthropic.claude-opus-5-5[1m]" mode= sid= prev= a m
    for a in "$@"; do
        case "$prev" in -r|--resume) case "$a" in -*) ;; *) sid=$a ;; esac ;; esac
        case "$a" in
            -c|--continue) mode=continue ;;
            --resume=*)    sid=${a#--resume=} ;;
        esac
        prev=$a
    done
    if [ -n "$sid" ] || [ "$mode" = continue ]; then
        m=$(_claude_session_model "$sid") && model=$m && echo "claude: resuming on $model" >&2
    fi
    # aws-vault refuses to nest; reuse this profile's creds when already inside it.
    if [ "$AWS_VAULT" = claude ]; then
        ANTHROPIC_MODEL="$model" command claude "$@"
    else
        ANTHROPIC_MODEL="$model" env -u AWS_VAULT aws-vault exec claude -- claude "$@"
    fi
}
alias claude-aws="claude"
alias claude-opus="ANTHROPIC_MODEL='us.anthropic.claude-opus-5-5[1m]' aws-vault exec claude -- claude"
alias claude55="ANTHROPIC_MODEL='us.anthropic.claude-opus-5-5[1m]' aws-vault exec claude -- claude"
alias claude47="ANTHROPIC_MODEL='us.anthropic.claude-opus-4-7' aws-vault exec claude -- claude"
alias claude-sonnet="ANTHROPIC_MODEL='global.anthropic.claude-sonnet-4-6' aws-vault exec claude -- claude"
alias fable="ANTHROPIC_MODEL='global.anthropic.claude-fable-5-1' aws-vault exec claude -- claude"
alias c55='claude55'
alias cc55='claude55'

# Model config/standalone launch behavior retained from natera.
alias opencode="OPENCODE_CONFIG_CONTENT='{\"model\":\"amazon-bedrock/us.anthropic.claude-opus-5-5\"}' aws-vault exec claude -- opencode --standalone"
alias opencode-claude="opencode"
alias opencode-opus="opencode"
alias opencode-sonnet="OPENCODE_CONFIG_CONTENT='{\"model\":\"amazon-bedrock/global.anthropic.claude-sonnet-5-5\"}' aws-vault exec claude -- opencode --standalone"

# Backwards compatibility
alias aws-opencode="opencode"
alias opencode-aws="opencode"
alias aws-opencode-claude="opencode-claude"
alias aws-opencode-opus="opencode-opus"
alias aws-opencode-sonnet="opencode-sonnet"

# Keep this last: the external repository may override these defaults.
export OPENCODE_CONFIG_REPO="$HOME/charlesreid1/opencode-config"
[ ! -r "$OPENCODE_CONFIG_REPO/.aliases" ] || source "$OPENCODE_CONFIG_REPO/.aliases"
