#!/usr/bin/env bash
# ==============================================================================
# File: scripts/05_zsh.sh
# Description: Installs Zsh, Oh My Zsh, Powerlevel10k, plugins, & restores dotfiles from config/.
# Standard: International Shell Script Architecture Standard (Google Style + POSIX)
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# Logging & Color Configuration
# ------------------------------------------------------------------------------
readonly LOG_COLOR_RESET="\033[0m"
readonly LOG_COLOR_INFO="\033[0;36m"    # Cyan
readonly LOG_COLOR_SUCCESS="\033[0;32m" # Green
readonly LOG_COLOR_WARN="\033[0;33m"    # Yellow
readonly LOG_COLOR_ERROR="\033[0;31m"   # Red

log_timestamp() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

log_info() {
  printf "%b[%s] [INFO] %s%b\n" "$LOG_COLOR_INFO" "$(log_timestamp)" "$*" "$LOG_COLOR_RESET" >&2
}

log_success() {
  printf "%b[%s] [SUCCESS] %s%b\n" "$LOG_COLOR_SUCCESS" "$(log_timestamp)" "$*" "$LOG_COLOR_RESET" >&2
}

log_warn() {
  printf "%b[%s] [WARN] %s%b\n" "$LOG_COLOR_WARN" "$(log_timestamp)" "$*" "$LOG_COLOR_RESET" >&2
}

log_error() {
  printf "%b[%s] [ERROR] %s%b\n" "$LOG_COLOR_ERROR" "$(log_timestamp)" "$*" "$LOG_COLOR_RESET" >&2
}

cleanup_on_error() {
  local exit_code=$1
  local line_no=$2
  log_error "Zsh module failed at line ${line_no} with exit code ${exit_code}."
}
trap 'cleanup_on_error $? $LINENO' ERR

# ------------------------------------------------------------------------------
# Module Execution
# ------------------------------------------------------------------------------

install_zsh_packages() {
  log_info "5.1/4 Installing zsh, git, curl, fzf, tldr, python3..."
  sudo apt update && sudo apt install -y zsh git curl fzf tldr python3
  log_success "Zsh dependency packages installed."
}

install_oh_my_zsh() {
  log_info "5.2/4 Checking and installing Oh My Zsh..."
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    log_success "Oh My Zsh installed successfully."
  else
    log_warn "Oh My Zsh already exists at ~/.oh-my-zsh, skipping."
  fi
}

install_theme_plugins() {
  local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  log_info "5.3/4 Installing Powerlevel10k theme and zsh plugins..."
  if [[ ! -d "${zsh_custom}/themes/powerlevel10k" ]]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${zsh_custom}/themes/powerlevel10k"
  fi

  if [[ ! -d "${zsh_custom}/plugins/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "${zsh_custom}/plugins/zsh-autosuggestions"
  fi

  if [[ ! -d "${zsh_custom}/plugins/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${zsh_custom}/plugins/zsh-syntax-highlighting"
  fi

  log_success "Powerlevel10k theme and plugins installed successfully."
}

restore_dotfiles() {
  log_info "5.4/4 Restoring dotfiles from config/ directory..."
  local repo_dir config_dir
  repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  config_dir="${repo_dir}/config"

  if [[ -f "${config_dir}/zshrc" ]]; then
    cp "${config_dir}/zshrc" "$HOME/.zshrc"
    log_success "Restored ~/.zshrc."
  fi

  if [[ -f "${config_dir}/p10k.zsh" ]]; then
    cp "${config_dir}/p10k.zsh" "$HOME/.p10k.zsh"
    log_success "Restored ~/.p10k.zsh."
  fi

  if [[ -f "${config_dir}/bashrc" ]]; then
    cp "${config_dir}/bashrc" "$HOME/.bashrc"
    log_success "Restored ~/.bashrc."
  fi

  local zsh_path
  zsh_path="$(command -v zsh)"
  if [[ "$SHELL" != "$zsh_path" ]]; then
    sudo chsh -s "$zsh_path" "$USER" || log_warn "Password or manual chsh required to change shell."
    log_success "Changed default shell to Zsh (${zsh_path})."
  fi
}

main() {
  log_info "[MODULE 5/5] Starting Zsh Shell & Dotfiles Configuration..."
  install_zsh_packages
  install_oh_my_zsh
  install_theme_plugins
  restore_dotfiles
  log_success "[MODULE 5/5] Zsh Shell & Dotfiles Configuration Completed Successfully!"
}

main "$@"
