#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${HOME}/.config"
TMUX_DIR="${CONFIG_DIR}/tmux"
TMUX_TARGET="${TMUX_DIR}/tmux.conf"
NVIM_TARGET="${CONFIG_DIR}/nvim"

link_path() {
  local source_path="$1"
  local target_path="$2"

  mkdir -p "$(dirname "${target_path}")"

  if [ -L "${target_path}" ]; then
    local current_target
    current_target="$(readlink "${target_path}")"
    if [ "${current_target}" = "${source_path}" ]; then
      printf 'ok    %s already points to %s\n' "${target_path}" "${source_path}"
      return
    fi
  elif [ -e "${target_path}" ]; then
    printf 'skip  %s exists and is not a symlink\n' "${target_path}"
    return
  fi

  ln -sfn "${source_path}" "${target_path}"
  printf 'link  %s -> %s\n' "${target_path}" "${source_path}"
}

install_tpm() {
  local tpm_dir="${HOME}/.tmux/plugins/tpm"

  if [ -d "${tpm_dir}" ]; then
    printf 'ok    TPM already installed at %s\n' "${tpm_dir}"
    return
  fi

  mkdir -p "$(dirname "${tpm_dir}")"
  git clone https://github.com/tmux-plugins/tpm "${tpm_dir}"
  printf 'done  installed TPM at %s\n' "${tpm_dir}"
}

mkdir -p "${CONFIG_DIR}" "${TMUX_DIR}"

link_path "${DOTFILES_DIR}/tmux/tmux.conf" "${TMUX_TARGET}"
link_path "${DOTFILES_DIR}/nvim" "${NVIM_TARGET}"
install_tpm

printf '\nSetup complete.\n'
printf 'tmux config: %s\n' "${TMUX_TARGET}"
printf 'nvim config: %s\n' "${NVIM_TARGET}"
printf 'Edit files in %s and the machine will use them directly.\n' "${DOTFILES_DIR}"
