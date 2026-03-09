#!/usr/bin/env python3
import os, tarfile, time
from datetime import datetime

BASE = "/mnt/stateful_partition/murkmod"
BACK = BASE + "/backups"
if not os.path.isdir(BACK):
    try:
        os.makedirs(BACK)
    except:
        pass

t = datetime.now().strftime("%Y%m%d-%H%M%S")
pid = str(os.getpid())
mix = str(int(time.time()))[-6:]
name = "mushm_backup_" + t + "_" + pid + "_" + mix + ".tar.gz"
out = BACK + "/" + name

targets = [
    ("plugins", BASE + "/plugins"),
    ("pollen", BASE + "/pollen"),
    ("crosh", "/usr/bin/crosh"),
    ("chromeos_startup", "/sbin/chromeos_startup"),
]

mp = "/etc/opt/chrome/policies/managed"
if os.path.exists(mp):
    targets.append(("managed_policies", mp))

with tarfile.open(out, "w:gz") as tar:
    for arc, path in targets:
        if os.path.exists(path):
            if os.path.isdir(path):
                for root, dirs, files in os.walk(path):
                    for d in dirs:
                        p = os.path.join(root, d)
                        a = arc + "/" + os.path.relpath(p, path)
                        tar.add(p, arcname=a)
                    for f in files:
                        p = os.path.join(root, f)
                        a = arc + "/" + os.path.relpath(p, path)
                        tar.add(p, arcname=a)
            else:
                tar.add(path, arcname=arc)
    time.sleep(0.1)

print("Backup created:", out)
