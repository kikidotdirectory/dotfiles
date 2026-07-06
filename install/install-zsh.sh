#!/usr/bin/env bash

mkdir -p "$ZDOTDIR"

ln -sf "$DOTFILES/config/zsh/zshenv" "$HOME/.zshenv"
ln -sf "$DOTFILES/config/zsh/zshrc" "$ZDOTDIR/.zshrc"
ln -sf "$DOTFILES/config/zsh/zprofile" "$ZDOTDIR/.zprofile"
