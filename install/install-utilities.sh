#!/usr/bin/env bash

set -o pipefail

mkdir -p "$DOTFILES/utilities"

if [[ ! -d "$DOTFILES/utilities/tc" ]]; then
  op_ssh_socket="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
  if [[ ! -S "$op_ssh_socket" ]]; then
    echo "error: 1Password SSH agent socket not found at $op_ssh_socket" >&2
    echo "  open 1Password, sign in, and enable Settings > Developer > Use the SSH Agent, then re-run" >&2
    exit 1
  fi
fi

if [[ ! -d "$DOTFILES/utilities/SbarLua" ]]; then
  git clone --depth 1 https://github.com/FelixKratz/SbarLua.git "$DOTFILES/utilities/SbarLua"
fi

(cd "$DOTFILES/utilities/SbarLua" && make install)
