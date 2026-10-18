# Personal AI tools (formerly on main).
alias oc='opencode'
alias astra='opencode --model openrouter/openai/gpt-6-astra-pro'

alias gemini-flash='gemini --model gemini-3-flash-preview'
alias gemini-pro='gemini --model gemini-3-pro-preview'

alias claude='command claude --model claude-opus-5-5'
alias claude-haiku='claude --model claude-haiku-4-5'
alias claude-sonnet='claude --model claude-sonnet-4-6'

export DEEPSEEK_ARGS="ANTHROPIC_DEFAULT_HAIKU_MODEL='deepseek-flash' CLAUDE_CODE_MAX_CONTEXT_TOKENS=1048576 MAX_THINKING_TOKENS=0 API_TIMEOUT_MS=600000"
alias claude-deep="ANTHROPIC_BASE_URL='https://api.deepseek.com/anthropic'     ANTHROPIC_MODEL='deepseek-v4-pro' ANTHROPIC_AUTH_TOKEN='$DEEPSEEK_API_KEY' ${DEEPSEEK_ARGS} claude"
alias claude-deeplite="ANTHROPIC_BASE_URL='https://api.deepseek.com/anthropic' ANTHROPIC_MODEL='deepseek-flash'  ANTHROPIC_AUTH_TOKEN='$DEEPSEEK_API_KEY' ${DEEPSEEK_ARGS} claude"

# oh-my-openagent personal profiles
alias omo-pd="command cp ~/code/oh-my-openagent-config/personal-deepseek.json ~/.config/opencode/oh-my-openagent.json && echo 'omo: personal-deepseek'"
alias omo-pg="command cp ~/code/oh-my-openagent-config/personal-gemini.json ~/.config/opencode/oh-my-openagent.json && echo 'omo: personal-gemini'"
alias omo-pm="command cp ~/code/oh-my-openagent-config/personal-multi.json ~/.config/opencode/oh-my-openagent.json && echo 'omo: personal-multi'"
alias omo-pb="command cp ~/code/oh-my-openagent-config/personal-budget.json ~/.config/opencode/oh-my-openagent.json && echo 'omo: personal-budget'"

alias council="OPENCODE_CONFIG_DIR=$HOME/code/opencode-config/bedrock-council-markdown-bio opencode --pure"
