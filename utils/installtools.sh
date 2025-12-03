#!/bin/bash
set -e
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then TARGET="x86_64"; else TARGET="arm"; fi
INSTALL=/usr/local/bin
if [[ $EUID -ne 0 ]]; then echo run with sudo; exit 1; fi
mount -o remount,rw /
mkdir -p "$INSTALL"

if [[ "$TARGET" == "x86_64" ]]; then
BB_URL="https://busybox.net/downloads/binaries/1.36.1-defconfig-multiarch/busybox-x86_64"
NANO_URL="https://static.ripper234.com/nano/nano-x86_64"
HTOP_URL="https://github.com/hishamht/htop/releases/download/3.2.2/htop-x86_64"
NC_URL="https://static.ripper234.com/nc-x86_64"
WGET_URL="https://eternallybored.org/misc/wget/releases/wget-latest-linux-x86_64"
UNZIP_URL="https://static.ripper234.com/unzip-x86_64"
ZIP_URL="https://static.ripper234.com/zip-x86_64"
SSH_BASE="https://static.ripper234.com/openssh/x86_64"
RSYNC_URL="https://static.ripper234.com/rsync-x86_64"
GIT_URL="https://static.ripper234.com/git-x86_64"
PY_URL="https://github.com/indygreg/python-build-standalone/releases/latest/download/python-3.11.0-x86_64-unknown-linux-gnu.tar.gz"
TMUX_URL="https://static.ripper234.com/tmux-x86_64"
FILE_URL="https://static.ripper234.com/file-x86_64"
JQ_URL="https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"
else
BB_URL="https://busybox.net/downloads/binaries/1.36.1-defconfig-multiarch/busybox-armv7l"
NANO_URL="https://static.ripper234.com/nano/nano-arm"
HTOP_URL="https://github.com/hishamht/htop/releases/download/3.2.2/htop-arm"
NC_URL="https://static.ripper234.com/nc-arm"
WGET_URL="https://eternallybored.org/misc/wget/releases/wget-latest-linux-arm"
UNZIP_URL="https://static.ripper234.com/unzip-arm"
ZIP_URL="https://static.ripper234.com/zip-arm"
SSH_BASE="https://static.ripper234.com/openssh/arm"
RSYNC_URL="https://static.ripper234.com/rsync-arm"
GIT_URL="https://static.ripper234.com/git-arm"
PY_URL="https://github.com/indygreg/python-build-standalone/releases/latest/download/python-3.11.0-aarch64-unknown-linux-gnu.tar.gz"
TMUX_URL="https://static.ripper234.com/tmux-arm"
FILE_URL="https://static.ripper234.com/file-arm"
JQ_URL="https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux-arm"
fi

curl -L "$BB_URL" -o "$INSTALL/busybox"
chmod +x "$INSTALL/busybox"
for CMD in sh ls cp mv rm mkdir ps top dmesg free mount umount cat grep awk sed tar gzip chmod chown ln kill stat touch more less du df; do ln -sf busybox "$INSTALL/$CMD"; done
curl -L "$NANO_URL" -o "$INSTALL/nano"; chmod +x "$INSTALL/nano"
curl -L "$HTOP_URL" -o "$INSTALL/htop"; chmod +x "$INSTALL/htop"
curl -L "$NC_URL" -o "$INSTALL/nc"; chmod +x "$INSTALL/nc"
curl -L "$WGET_URL" -o "$INSTALL/wget"; chmod +x "$INSTALL/wget"
curl -L "$UNZIP_URL" -o "$INSTALL/unzip"; chmod +x "$INSTALL/unzip"
curl -L "$ZIP_URL" -o "$INSTALL/zip"; chmod +x "$INSTALL/zip"
for T in ssh scp ssh-keygen ssh-keyscan; do curl -L "$SSH_BASE/$T" -o "$INSTALL/$T"; chmod +x "$INSTALL/$T"; done
curl -L "$RSYNC_URL" -o "$INSTALL/rsync"; chmod +x "$INSTALL/rsync"
curl -L "$GIT_URL" -o "$INSTALL/git"; chmod +x "$INSTALL/git"
curl -L "$PY_URL" -o /tmp/python.tar.gz
mkdir -p /opt/python
tar -xzf /tmp/python.tar.gz -C /opt/python --strip-components 1
mkdir -p /usr/local/lib/python3.11/site-packages
ln -sf /opt/python/bin/python3 "$INSTALL/python3"
ln -sf /opt/python/bin/pip3 "$INSTALL/pip3"
ln -sf /opt/python/bin/pip3 "$INSTALL/pip"
ln -sf /opt/python/bin/python3 "$INSTALL/python"
export PYTHONUSERBASE=/usr/local/lib/python3.11
export PATH="$INSTALL:$PATH"
curl -L "$TMUX_URL" -o "$INSTALL/tmux"; chmod +x "$INSTALL/tmux"
curl -L "$FILE_URL" -o "$INSTALL/file"; chmod +x "$INSTALL/file"
curl -L "$JQ_URL" -o "$INSTALL/jq"; chmod +x "$INSTALL/jq"
echo done
echo export PATH=\"/usr/local/bin:\$PATH\"
echo export PYTHONUSERBASE=/usr/local/lib/python3.11
