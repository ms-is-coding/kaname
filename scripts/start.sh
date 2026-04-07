#!/usr/bin/env bash
set -e

IMAGE="osdev"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

DISPLAY_ARGS=()

# X11
if [ -n "$DISPLAY" ]; then
    DISPLAY_ARGS+=(
        -v /tmp/.X11-unix:/tmp/.X11-unix
        -e DISPLAY="$DISPLAY"
    )
fi

# Wayland
if [ -n "$WAYLAND_DISPLAY" ]; then
    WAYLAND_SOCK="${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY}"
    if [ -S "$WAYLAND_SOCK" ]; then
        DISPLAY_ARGS+=(
            -v "$WAYLAND_SOCK:/tmp/$WAYLAND_DISPLAY"
            -e WAYLAND_DISPLAY="$WAYLAND_DISPLAY"
            -e XDG_RUNTIME_DIR=/tmp
        )
    fi
fi

if [ ${#DISPLAY_ARGS[@]} -eq 0 ]; then
    echo "Warning: no display server detected (DISPLAY and WAYLAND_DISPLAY are unset)"
    echo "QEMU graphical output will not work"
fi

exec podman run --rm -it \
    -v "$PROJECT_DIR:/os" \
    "${DISPLAY_ARGS[@]}" \
    "$IMAGE"
