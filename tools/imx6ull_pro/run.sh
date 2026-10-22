#!/bin/sh
set -eu

APP_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$APP_DIR"

if [ -n "${LD_LIBRARY_PATH:-}" ]; then
    export LD_LIBRARY_PATH="$APP_DIR/lib:$LD_LIBRARY_PATH"
else
    export LD_LIBRARY_PATH="$APP_DIR/lib"
fi

export LV_LINUX_EVDEV_POINTER_DEVICE="${LV_LINUX_EVDEV_POINTER_DEVICE:-/dev/input/event1}"

exec "$APP_DIR/lvglsim" "$@"
