#!/usr/bin/env python3
import os
import shutil
from pathlib import Path

home_dir = str(Path.home())
zshrc_sys = os.path.join(home_dir, ".zshrc")
p10k_sys = os.path.join(home_dir, ".p10k.zsh")

repo_dir = os.path.dirname(os.path.abspath(__file__))
zsh_repo_dir = os.path.join(repo_dir, "zsh")

os.makedirs(zsh_repo_dir, exist_ok=True)

try:
    if os.path.exists(zshrc_sys):
        shutil.copy2(zshrc_sys, os.path.join(zsh_repo_dir, ".zshrc"))
        print("Copied: ~/.zshrc")
    
    if os.path.exists(p10k_sys):
        shutil.copy2(p10k_sys, os.path.join(zsh_repo_dir, ".p10k.zsh"))
        print("Copied: ~/.p10k.zsh")
        
    print("Backup completed successfully.")
except Exception as e:
    print(f"Error: {e}")
