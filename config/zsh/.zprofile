typeset -U path fpath

# Personal bin dirs
path=(
  "$HOME/.local/bin"
  "$HOME/.local/share/bob/nvim-bin" # nvim version management
  $path
)

# Homebrew, fnm, zoxide
eval "$(/opt/homebrew/bin/brew shellenv)"
# eval "$(fnm env --shell zsh)"
# eval "$(zoxide init zsh)"

# Completions
fpath=("$HOME/Helpers/completions" $fpath)
autoload -Uz compinit
compinit

# Python 3.14
path=(
  "/Library/Frameworks/Python.framework/Versions/3.14/bin"
  $path
)

# MacPorts (installer originally added 2026-07-07_at_00:01:33)
path=(
  "/opt/local/bin"
  "/opt/local/sbin"
  $path
)

# Obsidian
path+=("/Applications/Obsidian.app/Contents/MacOS")

export PATH
