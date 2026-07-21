# AOSP & Flutter Dotfiles / Automated Ubuntu Setup

Repository containing Dotfiles configurations, Ubuntu environment backups, and a 1-Click automated system setup workflow for Android AOSP, Flutter, Web, and DevOps workstations.

---

## 🏗️ Repository Architecture

The repository is structured following enterprise DevOps standards for dotfiles management and automated workstation provisioning:

```
aosp-flutter-dotfiles/
├── README.md                 # Architecture documentation & usage guide
├── LICENSE                   # License file
├── setup.sh                  # 1-Click Master Entrypoint Script
├── config/                   # Centralized configuration & package manifests
│   ├── bashrc                # Backed up .bashrc
│   ├── zshrc                 # Backed up .zshrc
│   ├── p10k.zsh              # Backed up Powerlevel10k theme configuration
│   ├── apt_packages.txt      # List of manually installed APT packages
│   └── snap_packages.txt     # List of installed Snap packages
├── backups/                  # System archive backups
│   └── opt_backup.tar.gz     # Archive backup of /opt directory
└── scripts/                  # Numbered modular setup scripts
    ├── 01_system.sh          # System update, base tools, 64GB swap, power settings
    ├── 02_aosp.sh            # AOSP & Android Kernel build dependencies + Google repo tool
    ├── 03_dev_tools.sh       # Chrome, NVM, Node.js LTS, Snap apps, & /opt restore
    ├── 04_desktop.sh         # Vietnamese input method (ibus-bamboo)
    ├── 05_zsh.sh             # Zsh, Oh My Zsh, Powerlevel10k, plugins & dotfiles restore
    └── export_env.sh         # Environment export utility script
```

---

## 📐 International Shell Script Architecture Standard

All `.sh` scripts in this repository strictly adhere to the **International Shell Script Architecture Standard**:

### 1. Shebang & Strict Execution Mode
Every script begins with a portable shebang and enables `set -euo pipefail`:
```bash
#!/usr/bin/env bash
set -euo pipefail
```
- `set -e`: Exit immediately if any command fails (`exit status != 0`).
- `set -u`: Treat unset variables as an error and exit immediately.
- `set -o pipefail`: Return the exit status of the last command in a pipeline that failed.

---

### 2. Standardized Logging Framework
All log outputs are handled by standardized Logger functions:
- **ISO-8601 Timestamps** (`YYYY-MM-DDTHH:MM:SSZ`).
- **ANSI Color Coding**: Cyan (`INFO`), Green (`SUCCESS`), Yellow (`WARN`), Red (`ERROR`).
- **Stream Redirection**: Output dispatched to `stderr` (`>&2`) to avoid polluting `stdout` command pipelines.

---

### 3. Automated Error Trapping
An error trap handler (`trap`) captures and logs the exact file line number and exit code upon failure:
```bash
cleanup_on_error() {
  local exit_code=$1
  local line_no=$2
  log_error "Script failed at line ${line_no} with exit code ${exit_code}."
}
trap 'cleanup_on_error $? $LINENO' ERR
```

---

### 4. Idempotency & Reusability
- Operations check for state/file existence before executing to guarantee safe re-runs.
- All variables are explicitly quoted (`"$VAR"`) to avoid word-splitting.

---

## 🚀 1-Click Installation Guide

After installing a fresh Ubuntu OS, clone the repository and run the single master setup script:

```bash
git clone https://github.com/ChunhThanhDe/aosp-flutter-dotfiles.git
cd aosp-flutter-dotfiles
chmod +x setup.sh
./setup.sh
```

### Module Breakdown executed by `./setup.sh`:
1. `scripts/01_system.sh`: Updates system packages, installs base CLI utilities, provisions a 64GB Swap file, and configures power settings.
2. `scripts/02_aosp.sh`: Installs build packages for AOSP & Kernel compilation, and downloads the Google `repo` tool.
3. `scripts/03_dev_tools.sh`: Installs Google Chrome, NVM, Node.js LTS, Git global configs, Snap applications (Android Studio, Telegram, RustDesk), and restores `/opt` from `backups/opt_backup.tar.gz`.
4. `scripts/04_desktop.sh`: Installs and configures the Vietnamese input method (`ibus-bamboo`).
5. `scripts/05_zsh.sh`: Installs Zsh, Oh My Zsh, Powerlevel10k theme, Zsh plugins, restores dotfiles (`.zshrc`, `.p10k.zsh`, `.bashrc`) from `config/`, and sets Zsh as the default shell.

### Environment Export Utility
To export current system state and update manifests in `config/`:
```bash
./scripts/export_env.sh
```
