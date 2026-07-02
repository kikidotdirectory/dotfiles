#compdef install.sh

_install_sh() {
  local script_path="${words[1]}"
  local root_dir

  if [[ -e $script_path ]]; then
    root_dir="$(cd "$(dirname "$script_path")" && pwd)"
  else
    root_dir="$HOME/dotfiles"
  fi

  if (( CURRENT == 2 )); then
    local -a candidates
    candidates=("${(@f)$(find "$root_dir" -mindepth 1 -maxdepth 1 -type d ! -name '.*' ! -name config -exec basename {} \; 2>/dev/null | sort)}")
    candidates+=("${(@f)$(find "$root_dir/config" -mindepth 1 -maxdepth 1 -type d ! -name '.*' -exec basename {} \; 2>/dev/null | sed 's#^#config/#' | sort)}")
    candidates+=(all)
    _describe 'target' candidates
  fi
}

_install_sh "$@"
