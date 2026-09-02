#!/usr/bin/env bash

set -o pipefail

mkdir -p "$DOTFILES/utilities"

if [[ ! -d "$DOTFILES/utilities/tc" ]]; then
  git clone git@github.com:kikidotdirectory/tc.git "$DOTFILES/utilities/tc"
fi

(cd "$DOTFILES/utilities/tc" && npm install && npm run build && npm link)
