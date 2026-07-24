# Enable completion
autoload -Uz compinit
compinit

_comp_options+=(globdots) # include hidden files
source $DOTFILES/config/zsh/completion.zsh

source /opt/homebrew/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# Aliases
source $DOTFILES/config/zsh/aliases/aliases

# Functions
source $DOTFILES/config/zsh/functions.zsh

# Deno runtime environment
. "/Users/kiki/.deno/env"

eval "$(fnm env --use-on-cd --shell zsh)"
eval "$(direnv hook zsh)"
eval "$(zoxide init zsh)"

# SSH ────────────────────────────────────────────────────────────────
ssh-add --apple-load-keychain -q
