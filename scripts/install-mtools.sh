#!/usr/bin/env bash
set -e

PREFIX="$1"

if [ -z "$PREFIX" ]; then
    echo "Usage: install-mtools.sh <prefix>"
    exit 1
fi

BUILD_DIR="$(pwd)/.mtools-build"
INSTALL_DIR="${PREFIX}"

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

if [ -f "${INSTALL_DIR}/bin/mformat" ]; then
    echo "mtools already installed."
    exit 0
fi

echo "Downloading mtools..."
curl -LO https://mirrors.dotsrc.org/gnu/mtools/mtools-4.0.43.tar.gz
tar -xzf mtools-4.0.43.tar.gz
cd mtools-4.0.43

./configure --prefix="$INSTALL_DIR"
make -j
make install

cd ..
rm -rf mtools-4.0.43 mtools-4.0.43.tar.gz

echo "mtools installed to ${INSTALL_DIR}/bin"
