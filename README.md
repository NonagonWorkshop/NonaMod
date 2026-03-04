# NonaMod

Welcome, we are the team behind **Nonamod** and the modified version of **Mush**.  
This installer sets up the NonaMod environment and installs our better Mush, trust.

> [!WARNING]
> Installing NonaMod will **replace your existing Mush installation**.  
> Back up any important data before proceeding.  
> Terms and conditions may change at any time.  
> **We are not responsible for any damage to your system.** By using NonaMod, you agree to these terms.

---

## Installation

Run the following command as **root** to install the modified Mush

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/NonagonWorkshop/NonaMod/main/installer.sh)
```
---

## Features

```bash
+ FM Util Script
+ Reboot
+ Tetris
```
---

## Fixes

### Fix for "Can't Install Mushm" (Read-Only File System)

If you're seeing a "Read-Only" (RO) file system error when trying to install **Mushm** or any other package on Chrome OS, follow the steps below to fix it.

#### Step 1: Remount Root as Read-Write

1. Boot Sh1mmer
2. Open **bash Shell**.
3. Run the following command to remount the root file system with read-write access:

   ```bash
   sudo mount -o remount,rw /
   ```
3.1 If no reply, reboot and proceed to installation

3.2 If it replies with RO(Read Only) file system Procead to step 4

4. Run the following command to fix the RO error:

```bash
# replace /dev/mmcblk1p5 with the partition with the RO error
e2fsck -f /dev/mmcblk1p5
```

5. Reboot and proceed to installation

## Disable RootFS Verification (if sudo /usr/share/vboot/bin/make_dev_ssd.sh -i /dev/mmcblk0 --remove_rootfs_verification --partitions 2 (or --partitions 4) does not work)

1. Open **VT2 Shell**
2. Log in as root.

3. cd /usr/share/vboot/bin

4. sudo -E /usr/share/vboot/bin/make_dev_ssd.sh --partitions 2

