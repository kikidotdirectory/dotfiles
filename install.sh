#!/usr/bin/env bash
# Symlinks folders in this dotfiles repo into the right place under $HOME.
#
# Layout convention:
#   config/<name>  -> ~/.config/<name>   (app configs)
#   <name>         -> ~/<name>           (top-level tooling, e.g. Helpers)
#
# Usage:
#   ./install.sh <name>          symlink a root-level folder, e.g. ./install.sh Helpers
#   ./install.sh config/<name>   symlink a config app, e.g. ./install.sh config/yazi
#   ./install.sh all             symlink everything
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$ROOT_DIR/config"

list_config_apps() {
  find "$CONFIG_SRC" -mindepth 1 -maxdepth 1 -type d ! -name '.*' -exec basename {} \; 2>/dev/null | sort
}

list_root_dirs() {
  find "$ROOT_DIR" -mindepth 1 -maxdepth 1 -type d ! -name '.*' ! -name 'config' -exec basename {} \; 2>/dev/null | sort
}

link() {
  local source_dir="$1" target="$2"

  if [ -L "$target" ]; then
    if [ "$(readlink "$target")" = "$source_dir" ]; then
      echo "Already linked: $target -> $source_dir"
      return 0
    fi
    echo "Removing stale symlink at $target"
    rm "$target"
  elif [ -e "$target" ]; then
    local backup="${target}.bak.$(date +%Y%m%d%H%M%S)"
    echo "Backing up existing $target to $backup"
    mv "$target" "$backup"
  fi

  mkdir -p "$(dirname "$target")"
  ln -s "$source_dir" "$target"
  echo "Linked $target -> $source_dir"
}

link_config_app() { link "$CONFIG_SRC/$1" "$HOME/.config/$1"; }
link_root_dir()   { link "$ROOT_DIR/$1" "$HOME/$1"; }

usage() {
  echo "Usage: $0 <name>|config/<name>|all"
  echo
  echo "Available root folders (-> ~/<name>):"
  list_root_dirs | sed 's/^/  /'
  echo "Available config apps (-> ~/.config/<name>):"
  list_config_apps | sed 's/^/  config\//'
}

if [ "$#" -ne 1 ]; then
  usage
  exit 1
fi

arg="$1"

if [ "$arg" = "all" ]; then
  while IFS= read -r dir; do link_root_dir "$dir"; done < <(list_root_dirs)
  while IFS= read -r dir; do link_config_app "$dir"; done < <(list_config_apps)
  exit 0
fi

if [[ "$arg" == config/* ]]; then
  name="${arg#config/}"
  if [ ! -d "$CONFIG_SRC/$name" ] || [[ "$name" == .* ]]; then
    echo "Error: 'config/$name' is not a valid folder in $CONFIG_SRC" >&2
    echo >&2
    usage >&2
    exit 1
  fi
  link_config_app "$name"
  exit 0
fi

if [ ! -d "$ROOT_DIR/$arg" ] || [ "$arg" = "config" ] || [[ "$arg" == .* ]]; then
  echo "Error: '$arg' is not a valid folder in $ROOT_DIR" >&2
  echo >&2
  usage >&2
  exit 1
fi

link_root_dir "$arg"
