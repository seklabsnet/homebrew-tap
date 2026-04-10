#!/bin/sh
set -e

# Palbase CLI installer
# Usage: curl -fsSL https://get.palbase.io/install.sh | sh

REPO="seklabsnet/homebrew-tap"
INSTALL_DIR="/usr/local/bin"

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
  x86_64|amd64) ARCH="amd64" ;;
  arm64|aarch64) ARCH="arm64" ;;
  *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

case "$OS" in
  darwin|linux) ;;
  *) echo "Unsupported OS: $OS"; exit 1 ;;
esac

# Get latest version
VERSION=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$VERSION" ]; then
  echo "Failed to get latest version"
  exit 1
fi

echo "Installing palbase ${VERSION} (${OS}/${ARCH})..."

# Download
URL="https://github.com/${REPO}/releases/download/${VERSION}/palbase_${OS}_${ARCH}.tar.gz"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

curl -fsSL "$URL" -o "${TMP_DIR}/palbase.tar.gz"
tar -xzf "${TMP_DIR}/palbase.tar.gz" -C "$TMP_DIR"

# Install
if [ -w "$INSTALL_DIR" ]; then
  mv "${TMP_DIR}/palbase" "${INSTALL_DIR}/palbase"
else
  echo "Need sudo to install to ${INSTALL_DIR}"
  sudo mv "${TMP_DIR}/palbase" "${INSTALL_DIR}/palbase"
fi

chmod +x "${INSTALL_DIR}/palbase"

echo "✓ palbase ${VERSION} installed to ${INSTALL_DIR}/palbase"
echo ""
echo "Get started:"
echo "  palbase login"
echo "  palbase backend init my-app"
