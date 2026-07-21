#!/usr/bin/env bash
# ==============================================================================
# File: scripts/04_desktop.sh
# Description: Installs and configures Vietnamese input method (ibus-bamboo).
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
  log_error "Desktop module failed at line ${line_no} with exit code ${exit_code}."
}
trap 'cleanup_on_error $? $LINENO' ERR

# ------------------------------------------------------------------------------
# Module Execution
# ------------------------------------------------------------------------------

install_ibus_bamboo() {
  log_info "4.1/1 Installing Vietnamese input method (ibus-bamboo)..."
  if ! dpkg -s ibus-bamboo &>/dev/null; then
    sudo add-apt-repository ppa:bamboo-engine/ibus-bamboo -y
    sudo apt update
    sudo apt install -y ibus-bamboo
    im-config -n ibus || true
    log_success "ibus-bamboo installed and configured successfully."
  else
    log_warn "ibus-bamboo input method is already installed."
  fi
}

main() {
  log_info "[MODULE 4/5] Starting Desktop Environment & Input Method Setup..."
  install_ibus_bamboo
  log_success "[MODULE 4/5] Desktop Environment Setup Completed Successfully!"
}

main "$@"
