#!/usr/bin/env zsh

# y – Yazi file manager wrapper that changes the shell's working
#     directory to wherever you navigate when you quit Yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# Helper to quickly navigate to ~/Projects
p() {
  if [[ -z "$1" ]]; then
    cd ~/Projects
  else
    cd ~/Projects/"$1"
  fi
}

_p() {
  local -a dirs
  dirs=(~/Projects/*(/N:t))
  _describe 'project' dirs
}
compdef _p p
