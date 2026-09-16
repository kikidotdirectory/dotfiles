#!/usr/bin/env bash

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

ln -sf "$DOTFILES/config/ssh/config" "$HOME/.ssh/config"

op_ssh_socket="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
if [[ ! -S "$op_ssh_socket" ]]; then
  echo "warning: 1Password SSH agent socket not found at $op_ssh_socket" >&2
  echo "  open 1Password, sign in, and enable Settings > Developer > Use the SSH Agent" >&2
fi
