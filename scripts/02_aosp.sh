#!/usr/bin/env bash
# ==============================================================================
# File: scripts/02_aosp.sh
# Description: Installs build dependencies for Android AOSP & Kernel, plus Google repo tool.
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
  log_error "AOSP module failed at line ${line_no} with exit code ${exit_code}."
}
trap 'cleanup_on_error $? $LINENO' ERR

# ------------------------------------------------------------------------------
# Module Execution
# ------------------------------------------------------------------------------

install_aosp_packages() {
  log_info "2.1/2 Installing build packages for Android AOSP & Kernel..."
  sudo apt install -y \
    git-core gnupg flex bison build-essential zip curl zlib1g-dev \
    libc6-dev-i386 libncurses6 libncurses-dev x11proto-core-dev libx11-dev \
    lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig ccache
  log_success "AOSP build packages installed successfully."
}

install_repo_tool() {
  log_info "2.2/2 Installing Google repo tool into ~/.local/bin..."
  mkdir -p "$HOME/.local/bin"
  if [[ ! -f "$HOME/.local/bin/repo" ]]; then
    curl -fsSL https://storage.googleapis.com/git-repo-downloads/repo > "$HOME/.local/bin/repo"
    chmod a+x "$HOME/.local/bin/repo"
    log_success "Google repo tool installed successfully at ~/.local/bin/repo."
  else
    log_warn "Google repo tool already exists at ~/.local/bin/repo, skipping."
  fi
}

main() {
  log_info "[MODULE 2/5] Starting Android AOSP & Kernel Build Environment Setup..."
  install_aosp_packages
  install_repo_tool
  log_success "[MODULE 2/5] AOSP Build Environment Setup Completed Successfully!"
}

main "$@"
