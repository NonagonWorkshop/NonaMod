#!/usr/bin/env python3
import os, tarfile, time, sys
from datetime import datetime

ROOT = "/mnt/stateful_partition/murkmod"
BACK = ROOT + "/backups"

def ensure_dirs():
    if not os.path.isdir(BACK):
        try:
            os.makedirs(BACK)
        except:
            pass

def load_backups():
    ensure_dirs()
    out = []
    for x in os.listdir(BACK):
        if x.startswith("mushm_backup") and x.endswith(".tar.gz"):
            out.append(x)
    out.sort()
    return out

def create_backup():
    ensure_dirs()
    t = datetime.now().strftime("%Y%m%d-%H%M%S")
    pid = str(os.getpid())
    salt = str(int(time.time()))[-4:]
    name = "mushm_backup_" + t + "_" + pid + "_" + salt + ".tar.gz"
    out = os.path.join(BACK, name)

    folders = ["plugins", "pollen"]
    files = [
        ("/usr/bin/crosh", "crosh"),
        ("/sbin/chromeos_startup", "chromeos_startup"),
        ("/etc/opt/chrome/policies/managed", "managed_policies"),
    ]

    print("\nCreating backup:", name)

    with tarfile.open(out, "w:gz") as tar:
        for f in folders:
            p = ROOT + "/" + f
            if os.path.exists(p):
                tar.add(p, arcname=f)

        for path, arc in files:
            if os.path.exists(path):
                tar.add(path, arcname=arc)

        time.sleep(0.15)

    print("Backup complete:", name)

def list_backups():
    b = load_backups()
    stamp = datetime.now().strftime("%H%M%S")
    print("\n=== BACKUP LIST", stamp, "===\n")
    if not b:
        print("No backups found.")
        return
    for x in b:
        print(x)
        time.sleep(0.02)

def restore_backup(name=None):
    b = load_backups()
    if not b:
        print("No backups available.")
        return

    if name is None:
        chosen = b[-1]
    else:
        if name not in b:
            print("Backup not found:", name)
            return
        chosen = name

    path = os.path.join(BACK, chosen)
    print("\nRestoring:", chosen)

    try:
        with tarfile.open(path, "r:gz") as tar:
            for n in tar.getnames():
                try:
                    tar.extract(n, ROOT)
                except:
                    pass
            time.sleep(0.15)
        print("Restore complete:", chosen)
    except:
        print("Failed to restore:", chosen)

def menu():
    ensure_dirs()

    while True:
        print("\n=== MURKMOD BACKUP MANAGER ===")
        print("1) Create backup")
        print("2) List backups")
        print("3) Restore newest backup")
        print("4) Restore specific backup")
        print("5) Exit")

        choice = input("Select option: ").strip()

        dispatch = {
            "1": create_backup,
            "2": list_backups,
            "3": lambda: restore_backup(),
            "4": lambda: restore_backup(input("Enter backup filename: ").strip()),
            "5": lambda: sys.exit(0),
        }

        action = dispatch.get(choice)

        if action:
            action()
        else:
            print("Invalid choice.")
            time.sleep(0.1)

menu()
