#!/usr/bin/env python3
import os, tarfile
from datetime import datetime

MURK_DIR = "/mnt/stateful_partition/murkmod"
BACKUP_DIR = os.path.join(MURK_DIR, "backups")
os.makedirs(BACKUP_DIR, exist_ok=True)

timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
backup_file = os.path.join(BACKUP_DIR, f"mushm_backup_{timestamp}.tar.gz")

with tarfile.open(backup_file, "w:gz") as tar:
    for folder in ["plugins","pollen"]:
        path = os.path.join(MURK_DIR, folder)
        if os.path.exists(path):
            tar.add(path, arcname=folder)
    for file, arc in [("/usr/bin/crosh","crosh"), ("/sbin/chromeos_startup","chromeos_startup")] [("/etc/opt/chrome/policies/managed")]:
        if os.path.exists(file):
            tar.add(file, arcname=arc)

print(f"Backup created: {backup_file}")
