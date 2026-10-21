# Corporate laptop (hostname: creid-mac; prompt name: natty).

# okta-aws-cli for legacy account CLI access
export OKTA_AWSCLI_ORG_DOMAIN=natera.okta.com
export OKTA_AWSCLI_OIDC_CLIENT_ID=0oaqmmhpit3hj0xl2297
export OKTA_AWSCLI_OPEN_BROWSER="true"
export OKTA_AWSCLI_WRITE_AWS_CREDENTIALS="true"

# ~/.okta/okta.yaml:
# awscli:
#   profiles:
#     natera-ecd-dev:
#       aws-acct-fed-app-id: "0oa1oj1zdvEEV8WPJ297"
#       aws-iam-idp: "arn:aws:iam::169413595963:saml-provider/OktaSSO-TF"
#       aws-iam-role: "arn:aws:iam::169413595963:role/ReadOnly"

export AWS_VAULT_BACKEND=file
export AWS_VAULT_PROMPT=terminal
export AWS_VAULT_KEYCHAIN_NAME="login"
# AWS_VAULT_FILE_PASSPHRASE belongs in ~/.extra (mode 600), not this repo.

# Natera Netskope
export AWS_CA_BUNDLE="$HOME/.aws/nskp_config/netskope-cert-bundle.pem"
export REQUESTS_CA_BUNDLE="$AWS_CA_BUNDLE"
export SSL_CERT_FILE="$AWS_CA_BUNDLE"
export NODE_EXTRA_CA_CERTS="$AWS_CA_BUNDLE"

# Natera Claude Code: Bedrock credentials are supplied by aws-vault aliases.
# https://go.confluence.natera.com/wiki/spaces/SRETOOLS/pages/383356332/Claude+Code+Onboarding
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-west-2
export ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION=us-west-2
export AWS_PROFILE="claude"
export CMUX_CLAUDE_HOOKS_DISABLED=1
# Thinking depth/output length: effortLevel in ~/.claude/settings.json.

# Natera Synapse (optional local secret)
[ ! -r "$HOME/.synapse_api_key" ] || source "$HOME/.synapse_api_key"

# Tell Git not to look for gettext.sh (pyenv compatibility).
export GIT_INTERNAL_GETTEXT_TEST_FALLBACKS=1

export GOENV_ROOT="$HOME/.goenv"
PATH="$GOENV_ROOT/bin:$PATH"
# goenv init and nvm are deliberately disabled: they slow down every new shell.

PATH="$HOME/.antigravity/antigravity/bin:$PATH"
PATH="$HOMEBREW_PREFIX/opt/openjdk/bin:$PATH"
