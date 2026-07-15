#!/usr/bin/env python3
import os
import shutil
from pathlib import Path

repo_dir = os.path.dirname(os.path.abspath(__file__))
zshrc_repo = os.path.join(repo_dir, "zsh", ".zshrc")
p10k_repo = os.path.join(repo_dir, "zsh", ".p10k.zsh")

home_dir = str(Path.home())
zshrc_sys = os.path.join(home_dir, ".zshrc")
p10k_sys = os.path.join(home_dir, ".p10k.zsh")

try:
    if not os.path.exists(zshrc_repo):
        print("Error: zsh/.zshrc not found in the repository.")
        exit(1)

    if os.path.exists(zshrc_sys):
        shutil.copy2(zshrc_sys, zshrc_sys + ".bak")
        print("Created backup: ~/.zshrc.bak")

    shutil.copy2(zshrc_repo, zshrc_sys)
    print("Restored: ~/.zshrc")
    
    if os.path.exists(p10k_repo):
        shutil.copy2(p10k_repo, p10k_sys)
        print("Restored: ~/.p10k.zsh")
        
    print("Restore completed. Run 'source ~/.zshrc' to apply changes.")
except Exception as e:
    print(f"Error: {e}")
