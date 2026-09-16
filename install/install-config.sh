#!/usr/bin/env bash
set -e

mkdir -p ~/.config

for src in ~/dotfiles/config/*; do
    name=$(basename "$src")
    dest=~/.config/"$name"

    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        mv "$dest" "$dest.bak"
    fi

    ln -sfn "$src" "$dest"
done
