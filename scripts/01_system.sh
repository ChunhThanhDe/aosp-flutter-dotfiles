#!/usr/bin/env bash
# ==============================================================================
# File: scripts/01_system.sh
# Description: System package updates, core tools, 64GB Swap, and power settings.
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
  log_error "System module failed at line ${line_no} with exit code ${exit_code}."
}
trap 'cleanup_on_error $? $LINENO' ERR

# ------------------------------------------------------------------------------
# Module Execution
# ------------------------------------------------------------------------------

update_and_install_base() {
  log_info "1.1/3 Updating system package lists and installing core utilities..."
  sudo apt update && sudo apt upgrade -y
  sudo apt install -y \
    git curl wget build-essential unzip zip net-tools \
    openssh-server gedit vlc exfatprogs fzf tldr python3
  log_success "System package update and core utilities installation complete."
}

setup_swap() {
  log_info "1.2/3 Configuring 64GB Swap space..."
  if ! swapon --show | grep -q "/swapfile"; then
    sudo swapoff -a || true
    if [[ -f /swapfile ]]; then
      sudo rm -f /swapfile
    fi
    sudo fallocate -l 64G /swapfile || sudo dd if=/dev/zero of=/swapfile bs=1M count=65536
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    log_success "64GB Swap file created and activated."
  else
    log_warn "64GB Swap space is already active."
  fi

  if ! grep -q "^/swapfile" /etc/fstab; then
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
  fi

  if ! grep -q "^vm.swappiness=10" /etc/sysctl.conf; then
    echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
  fi
  sudo sysctl -p || true
}

configure_power_settings() {
  log_info "1.3/3 Configuring system power and idle settings..."
  if command -v gsettings &>/dev/null; then
    gsettings set org.gnome.desktop.session idle-delay 0 || true
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing' || true
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing' || true
    log_success "System power settings configured to disable auto-sleep."
  else
    log_warn "gsettings tool not found, skipping GNOME power configuration."
  fi
}

main() {
  log_info "[MODULE 1/5] Starting System Base Configuration..."
  update_and_install_base
  setup_swap
  configure_power_settings
  log_success "[MODULE 1/5] System Base Configuration Completed Successfully!"
}

main "$@"
