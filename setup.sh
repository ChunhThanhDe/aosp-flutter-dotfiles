#!/usr/bin/env bash
# ==============================================================================
# File: setup.sh
# Description: Master orchestrator script for 1-Click Ubuntu system setup.
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
  log_error "Master setup orchestrator failed at line ${line_no} with exit code ${exit_code}."
}
trap 'cleanup_on_error $? $LINENO' ERR

# ------------------------------------------------------------------------------
# Orchestrator Main Execution
# ------------------------------------------------------------------------------

main() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  log_info "========================================================================"
  log_info "      STARTING 1-CLICK UBUNTU SYSTEM & DEVELOPMENT ENVIRONMENT SETUP    "
  log_info "========================================================================"

  # Ensure execution permissions for all modular scripts
  chmod +x "${script_dir}/scripts/"*.sh

  # Step 1: Base System & Swap
  log_info "Executing Module 1/5: System Base & Swap Configuration..."
  "${script_dir}/scripts/01_system.sh"

  # Step 2: AOSP Dependencies & repo tool
  log_info "Executing Module 2/5: AOSP & Kernel Build Environment..."
  "${script_dir}/scripts/02_aosp.sh"

  # Step 3: Dev Tools, Chrome, Node.js, Snap apps, & /opt restore
  log_info "Executing Module 3/5: Development Tools & /opt Restoration..."
  "${script_dir}/scripts/03_dev_tools.sh"

  # Step 4: Vietnamese Input Method
  log_info "Executing Module 4/5: Desktop & Vietnamese Input Method..."
  "${script_dir}/scripts/04_desktop.sh"

  # Step 5: Zsh Shell, Plugins, & Dotfiles
  log_info "Executing Module 5/5: Zsh Shell & Dotfiles Configuration..."
  "${script_dir}/scripts/05_zsh.sh"

  log_success "========================================================================"
  log_success "  🎉 CONGRATULATIONS! 1-CLICK UBUNTU SETUP HAS COMPLETED SUCCESSFULLY!  "
  log_success "========================================================================"
  log_info "Note: Please log out and log back in (or restart shell) to apply Zsh & NVM."
}

main "$@"
