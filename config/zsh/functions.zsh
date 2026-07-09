#!/usr/bin/env zsh

yset() {
  emulate -L zsh
  setopt local_options pipe_fail
  if [[ $# -eq 0 ]]; then
    echo "usage: yset <yashiki-subcommand> [args...]" >&2
    return 1
  fi
  if [[ -z "$DOTFILES" ]]; then
    echo "yset: \$DOTFILES is not set" >&2
    return 1
  fi
  local init_file="$DOTFILES/config/yashiki/init"
  local cmd="yashiki $*"
	# Run the actual yashiki command
  yashiki "$@"
  local exit_status=$?
  if [[ $exit_status -ne 0 ]]; then
    echo "yset: '$cmd' failed with status $exit_status, not appending to init" >&2
    return $exit_status
  fi
  # Make sure the directory exists
  mkdir -p "${init_file:h}"
  # Append the command to the init file, unless it's already there
  if ! grep -qxF -- "$cmd" "$init_file" 2>/dev/null; then
    echo "$cmd" >> "$init_file"
  fi
}
