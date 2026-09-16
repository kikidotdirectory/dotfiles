#!/usr/bin/env bash

set -o pipefail

source ./config/zsh/.zshenv

# for file in $ROOT_DIR/*(.); echo $file;

. "$DOTFILES/install/install-zsh.sh"
. "$DOTFILES/install/install-config.sh"
. "$DOTFILES/install/install-ssh.sh"
. "$DOTFILES/install/install-git.sh"
. "$DOTFILES/install/install-utilities.sh"

