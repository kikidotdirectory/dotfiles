#!/usr/bin/env zsh

# y – Yazi file manager wrapper that changes the shell's working
#     directory to wherever you navigate when you quit Yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd <"$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

tc() {
	if [ "$1" = "cd" ]; then
		cd "$(command tc cd)"
	else
		command tc "$@"
	fi
}

di() {
	dprint init "$@"
	jq '.useTabs = true' dprint.json >tmp.json && mv tmp.json dprint.json
}

# Dir jump helpers
function cd_dir() {
	local base="$1"
	local query="$2"
	local target

	if [[ -z "$query"]]; then
		cd "$base"
		return
	fi

	target=$(fd --type d --base-directory "$base" -i "$query" |
		awk '{ print gsub(/\//,"/"), $0 }' | sort -n | head -1 | cut -d' ' -f2-)
	if [ -n "$target" ]; then
		cd "$base/$target"
	else
		echo "No match for '$query'"
	fi
}

make_cd_shortcut() {
	local name="$1"
	local base="$2"

	# Define the wrapper function, e.g. `c`, `u`, `p`, etc.
	eval "
  ${name}() {
    cd_dir \"$base\" \"\$1\"
  }
  "
	# Define its matching completion function
	eval "
  _${name}_complete() {
    local -a dirs
    dirs=(\${(f)\"\$(fd --type d --base-directory \"$base\" . 2>/dev/null | xargs -n1 basename)\"})
    _describe 'directory' dirs
  }
  "

	compdef "_${name}_complete" "$name"
}

# directories
make_cd_shortcut c "$HOME/dotfiles"
make_cd_shortcut p "$HOME/Projects"
