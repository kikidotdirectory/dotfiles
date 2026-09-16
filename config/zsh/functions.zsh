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

di() {
	dprint init "$@"
	jq '.useTabs = true' dprint.json >tmp.json && mv tmp.json dprint.json
}

# Dir jump helpers
function cd_dir() {
	local base="$1"
	local query="$2"
	local maxdepth="$3"
	local target

	if [[ -z "$query" ]]; then
		cd "$base"
		return
	fi

	target=$(_cd_shortcut_dirs "$base" "$maxdepth" | grep -i -- "$query" |
		awk '{ print gsub(/\//,"/"), $0 }' | sort -n | head -1 | cut -d' ' -f2-)
	if [ -n "$target" ]; then
		cd "$base/$target"
	else
		echo "No match for '$query'"
	fi
}

typeset -gA _cd_shortcut_bases
typeset -gA _cd_shortcut_maxdepth

# Files/dirs that mark a project root. A directory containing any of
# these is treated as a leaf: it's listed, but we don't walk into it
# any further (so node_modules/.git internals and a project's own
# subfolders never show up as candidates).
typeset -ga _cd_shortcut_root_markers=(.git node_modules package.json deno.json)

# Lists directories under $1, relative to it (trailing slash, like
# `fd`'s), stopping descent at anything matching
# $_cd_shortcut_root_markers, and never descending past $2 levels deep
# (empty/unset means unlimited). Pure zsh (glob quals + [[ -e ]]) so it
# never forks a process per directory.
_cd_shortcut_dirs() {
	local base="$1"
	local maxdepth="$2"
	local -a stack=("") depths=(0)
	local rel dir marker sub is_root depth

	while (( ${#stack} )); do
		rel="${stack[1]}"
		depth="${depths[1]}"
		stack=("${stack[@]:1}")
		depths=("${depths[@]:1}")
		dir="$base${rel:+/$rel}"
		[[ -n "$rel" ]] && print -r -- "$rel/"

		is_root=0
		if [[ -n "$rel" ]]; then
			for marker in $_cd_shortcut_root_markers; do
				if [[ -e "$dir/$marker" ]]; then
					is_root=1
					break
				fi
			done
		fi

		(( is_root )) && continue
		[[ -n "$maxdepth" ]] && (( depth >= maxdepth )) && continue
		for sub in "$dir"/*(N/); do
			stack+=("${rel:+$rel/}${sub:t}")
			depths+=($((depth + 1)))
		done
	done
}

# Shared completion function for all shortcuts. Uses zsh's array `:t`
# modifier for basenames instead of forking `basename` once per line,
# and looks up its base dir via $service (the name of the command being
# completed, e.g. `c`/`p`; $0 would just be this function's own name),
# so a single function serves every shortcut.
_cd_shortcut_complete() {
	local base="$_cd_shortcut_bases[$service]"
	local maxdepth="$_cd_shortcut_maxdepth[$service]"
	local -a dirs
	dirs=(${${(f)"$(_cd_shortcut_dirs "$base" "$maxdepth")"}:t})
	# _describe wants the completions array passed by name (it does its
	# own indirection), not pre-expanded as values — passing values
	# makes it misparse them as extra description/array-name pairs.
	_describe 'directory' dirs
}

make_cd_shortcut() {
	local name="$1"
	local base="$2"
	local maxdepth="$3"

	_cd_shortcut_bases[$name]="$base"
	_cd_shortcut_maxdepth[$name]="$maxdepth"
	# Define the wrapper function, e.g. `c`, `u`, `p`, etc.
	functions[$name]='cd_dir "$_cd_shortcut_bases[$0]" "$1" "$_cd_shortcut_maxdepth[$0]"'

	compdef _cd_shortcut_complete "$name"
}

# directories
make_cd_shortcut c "$HOME/dotfiles"
make_cd_shortcut p "$HOME/Projects" 2
make_cd_shortcut d "$HOME/Documents" 1
