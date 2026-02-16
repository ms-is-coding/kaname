#!/usr/bin/env bash
set -e

VERSION="$1"
PREFIX="$2"

if [ -z "$VERSION" ] || [ -z "$PREFIX" ]; then
    echo "Usage: install-zig.sh <version> <prefix>"
    exit 1
fi

mkdir -p "$PREFIX"
cd "$PREFIX"

UNAME_S="$(uname -s)"
UNAME_M="$(uname -m)"

case "$UNAME_S" in
    Linux) OS="linux" ;;
    Darwin) OS="macos" ;;
    *) echo "Unsupported OS: $UNAME_S"; exit 1 ;;
esac

case "$UNAME_M" in
    x86_64) ARCH="x86_64" ;;
    aarch64|arm64) ARCH="aarch64" ;;
    *) echo "Unsupported architecture: $UNAME_M"; exit 1 ;;
esac

TARBALL="zig-${ARCH}-${OS}-${VERSION}.tar.xz"

if [ -d "zig" ]; then
    echo "Zig already installed."
    exit 0
fi

echo "Downloading Zig ${VERSION}..."
curl -LO "https://ziglang.org/download/${VERSION}/${TARBALL}"

tar -xf "${TARBALL}"
rm "${TARBALL}"

mv "zig-${ARCH}-${OS}-${VERSION}" zig

echo "Zig installed to $PREFIX/zig"
