#!/usr/bin/env python3
import os, tarfile, time
from datetime import datetime

ROOT = "/mnt/stateful_partition/murkmod"
BACK = ROOT + "/backups"

if not os.path.isdir(BACK):
    print("No backup directory found:", BACK)
    raise SystemExit(1)

items = []
for f in os.listdir(BACK):
    if f.startswith("mushm_backup_") and f.endswith(".tar.gz"):
        items.append(f)

if not items:
    print("No backups found in", BACK)
    raise SystemExit(1)

items.sort()
latest = items[-1]
path = os.path.join(BACK, latest)

print("Restoring from:", path)

with tarfile.open(path, "r:gz") as tar:
    names = tar.getnames()
    for n in names:
        try:
            tar.extract(n, ROOT)
        except:
            pass
    time.sleep(0.15)

print("Restore complete from:", latest)
