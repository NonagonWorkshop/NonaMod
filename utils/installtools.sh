#!/bin/bash
set -e

ARCH="$(uname -m)"
if [[ "$ARCH" == "x86_64" ]]; then
  BB_URL="https://busybox.net/downloads/binaries/1.36.1-defconfig-multiarch/busybox-x86_64"
  MICRO_URL="https://github.com/zyedidia/micro/releases/download/v2.0.14/micro-2.0.14-linux64.tar.gz"
  PY_URL="https://github.com/astral-sh/python-build-standalone/releases/latest/download/python-3.11.0-x86_64-unknown-linux-gnu.tar.gz"
elif [[ "$ARCH" == "aarch64" || "$ARCH" == "armv7l" ]]; then
  BB_URL="https://busybox.net/downloads/binaries/1.36.1-defconfig-multiarch/busybox-armv7l"
  MICRO_URL="https://github.com/zyedidia/micro/releases/download/v2.0.14/micro-2.0.14-linuxarm64.tar.gz"
  PY_URL="https://github.com/astral-sh/python-build-standalone/releases/latest/download/python-3.11.0-aarch64-unknown-linux-gnu.tar.gz"
else
  echo "Unsupported architecture: $ARCH"
  exit 1
fi

INSTALL_DIR="/usr/local/bin"
mkdir -p "$INSTALL_DIR"
mount -o remount,rw /

download_and_install() {
  URL="$1"
  OUT="$2"
  TIMEOUT_SEC=10
  if curl --max-time $TIMEOUT_SEC -fL "$URL" -o "$OUT"; then
    chmod +x "$OUT"
    echo "Installed $OUT"
    return 0
  else
    echo "Failed to download $URL → skip"
    return 1
  fi
}

# BusyBox
echo "[*] Installing BusyBox..."
if download_and_install "$BB_URL" "$INSTALL_DIR/busybox"; then
  for CMD in sh ls cp mv rm mkdir ps top dmesg free mount umount cat grep awk sed tar gzip; do
    ln -sf busybox "$INSTALL_DIR/$CMD"
  done
fi

# Micro editor
echo "[*] Installing Micro editor..."
TMPDIR=$(mktemp -d)
if curl --max-time 15 -fL "$MICRO_URL" -o "$TMPDIR/micro.tar.gz"; then
  tar -xzf "$TMPDIR/micro.tar.gz" -C "$TMPDIR"
  if [[ -f "$TMPDIR/micro" ]]; then
    mv "$TMPDIR/micro" "$INSTALL_DIR/micro"
    chmod +x "$INSTALL_DIR/micro"
    echo "Installed micro"
  else
    echo "micro binary not found in archive → skip"
  fi
else
  echo "Failed to download micro → skip"
fi
rm -rf "$TMPDIR"

# Python + pip (standalone)
echo "[*] Installing Python + pip..."
TMPDIR=$(mktemp -d)
if curl --max-time 15 -fL "$PY_URL" -o "$TMPDIR/python.tar.gz"; then
  mkdir -p /opt/python
  tar -xzf "$TMPDIR/python.tar.gz" -C /opt/python --strip-components 1
  ln -sf /opt/python/bin/python3 "$INSTALL_DIR/python3"
  ln -sf /opt/python/bin/pip3 "$INSTALL_DIR/pip3"
  chmod +x "$INSTALL_DIR/python3" "$INSTALL_DIR/pip3"
  echo "Installed python3 + pip3"
else
  echo "Failed to download Python tarball → skip"
fi
rm -rf "$TMPDIR"

echo "[*] Done. You might want to add:"
echo "    export PATH=\"$INSTALL_DIR:\$PATH\""
