export DOTFILES="$HOME/dotfiles"

# zsh
# .zshenv needs to be within system root, all other zsh files are live within ~./config/zsh
export ZDOTDIR="$HOME/.config/zsh"
export HISTFILE="$ZDOTDIR/.zhistory"    # History filepath
export HISTSIZE=10000                   # Maximum events for internal history
export SAVEHIST=10000                   # Maximum events in history file

# editor
export EDITOR="nvim"
export VISUAL="nvim"

