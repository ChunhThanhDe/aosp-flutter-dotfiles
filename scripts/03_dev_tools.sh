#!/usr/bin/env bash
# ==============================================================================
# File: scripts/03_dev_tools.sh
# Description: Installs Chrome, NVM, Node.js LTS, Git configs, Snap apps, & restores /opt backup.
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
  log_error "Development tools module failed at line ${line_no} with exit code ${exit_code}."
}
trap 'cleanup_on_error $? $LINENO' ERR

# ------------------------------------------------------------------------------
# Module Execution
# ------------------------------------------------------------------------------

install_chrome() {
  log_info "3.1/5 Checking and installing Google Chrome..."
  if ! command -v google-chrome &>/dev/null; then
    local tmp_deb
    tmp_deb="$(mktemp --suffix=.deb)"
    wget -qO "$tmp_deb" https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo apt install -y "$tmp_deb"
    rm -f "$tmp_deb"
    log_success "Google Chrome installed successfully."
  else
    log_warn "Google Chrome is already installed."
  fi
}

install_nvm_node() {
  log_info "3.2/5 Checking and installing NVM & Node.js LTS..."
  export NVM_DIR="$HOME/.nvm"
  if [[ ! -d "$NVM_DIR" ]]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  fi

  if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    # shellcheck source=/dev/null
    \. "$NVM_DIR/nvm.sh"
    nvm install --lts || true
    log_success "NVM and Node.js LTS configured successfully."
  else
    log_warn "Unable to load NVM immediately. Please restart your shell after script completion."
  fi
}

configure_git() {
  log_info "3.3/5 Configuring global Git user parameters..."
  git config --global user.name "Thanh Chung"
  git config --global user.email "chunhthanhde.dev@gmail.com"
  git config --global init.defaultBranch main
  log_success "Global Git user configuration complete."
}

install_snap_packages() {
  log_info "3.4/5 Installing Snap development applications..."
  if command -v snap &>/dev/null; then
    sudo snap install android-studio --classic || log_warn "Android Studio Snap already installed or failed."
    sudo snap install telegram-desktop || log_warn "Telegram Desktop Snap already installed or failed."
    sudo snap install rustdesk || log_warn "RustDesk Snap already installed or failed."
    log_success "Snap development applications installed successfully."
  else
    log_warn "Snap package manager not available on this system, skipping."
  fi
}

restore_opt_backup() {
  log_info "3.5/5 Checking and restoring /opt backup archive into /opt/..."
  local repo_dir archive_file
  repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  archive_file="${repo_dir}/backups/opt_backup.tar.gz"

  if [[ -f "$archive_file" ]]; then
    log_info "Extracting ${archive_file} directly into /opt/..."
    sudo tar -xzf "$archive_file" -C /opt/
    log_success "/opt backup archive restored successfully into /opt/."
  else
    log_warn "No opt_backup.tar.gz archive found at ${archive_file}, skipping."
  fi
}

main() {
  log_info "[MODULE 3/5] Starting Development Tools & Software Installation..."
  install_chrome
  install_nvm_node
  configure_git
  install_snap_packages
  restore_opt_backup
  log_success "[MODULE 3/5] Development Tools Setup Completed Successfully!"
}

main "$@"
