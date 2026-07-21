#!/usr/bin/env bash
# ==============================================================================
# File: scripts/export_env.sh
# Description: Exports environment configuration, package lists, and /opt backup into config/ and backups/.
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
  log_error "Environment export failed at line ${line_no} with exit code ${exit_code}."
}
trap 'cleanup_on_error $? $LINENO' ERR

# ------------------------------------------------------------------------------
# Export Execution
# ------------------------------------------------------------------------------

export_env() {
  local repo_dir config_dir backups_dir
  repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  config_dir="${repo_dir}/config"
  backups_dir="${repo_dir}/backups"
  mkdir -p "$config_dir" "$backups_dir"

  log_info "1/5 Exporting manually installed APT packages to config/apt_packages.txt..."
  apt-mark showmanual > "${config_dir}/apt_packages.txt"
  log_success "Exported apt_packages.txt."

  log_info "2/5 Exporting Snap packages to config/snap_packages.txt..."
  if command -v snap &>/dev/null; then
    snap list | awk 'NR>1 {print $1}' > "${config_dir}/snap_packages.txt"
    log_success "Exported snap_packages.txt."
  else
    log_warn "Snap is not installed on this system, skipping."
  fi

  log_info "3/5 Backing up ~/.bashrc to config/bashrc..."
  if [[ -f "$HOME/.bashrc" ]]; then
    cp "$HOME/.bashrc" "${config_dir}/bashrc"
    log_success "Backed up ~/.bashrc."
  fi

  log_info "4/5 Backing up ~/.zshrc and ~/.p10k.zsh to config/..."
  if [[ -f "$HOME/.zshrc" ]]; then
    cp "$HOME/.zshrc" "${config_dir}/zshrc"
    log_success "Backed up ~/.zshrc."
  fi

  if [[ -f "$HOME/.p10k.zsh" ]]; then
    cp "$HOME/.p10k.zsh" "${config_dir}/p10k.zsh"
    log_success "Backed up ~/.p10k.zsh."
  fi

  log_info "5/5 Backing up /opt directory into backups/opt_backup.tar.gz..."
  if [[ -d /opt ]] && [[ -n "$(ls -A /opt 2>/dev/null)" ]]; then
    sudo tar -czf "${backups_dir}/opt_backup.tar.gz" -C /opt .
    log_success "Backed up /opt directory to backups/opt_backup.tar.gz."
  else
    log_warn "/opt directory is empty or does not exist, skipping archive."
  fi

  log_success "Environment export completed successfully! Config: ${config_dir}, Backups: ${backups_dir}"
}

main() {
  log_info "Starting environment backup export..."
  export_env
}

main "$@"
