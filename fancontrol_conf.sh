#!/bin/bash

INSTALL_DIR_FILE="/usr/local/bin/ChromeOS_PowerControl.install_dir"

if [ -f "$INSTALL_DIR_FILE" ]; then
    INSTALL_DIR=$(cat "$INSTALL_DIR_FILE")
else
    INSTALL_DIR="/usr/local/bin/ChromeOS_PowerControl"
fi

INSTALL_DIR="${INSTALL_DIR%/}"

exec "$INSTALL_DIR/fancontrol" __monitor__ >> /var/log/fancontrol.log 2>&1
