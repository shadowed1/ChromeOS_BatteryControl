#!/bin/bash
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)
INSTALL_DIR_FILE="/usr/local/bin/ChromeOS_PowerControl.install_dir"
if [ -f "$INSTALL_DIR_FILE" ]; then
    INSTALL_DIR=$(cat "$INSTALL_DIR_FILE")
else
    INSTALL_DIR="/usr/local/bin/ChromeOS_PowerControl"
fi
INSTALL_DIR="${INSTALL_DIR%/}"
CONFIG_FILE="$INSTALL_DIR/config.sh"



remove_file_with_message() {
    local file="$1"
    if [ -f "$file" ]; then
        sudo rm "$file" && echo "Removed: $file"
    elif [ -L "$file" ]; then
        sudo rm "$file" && echo "Removed symlink: $file"
    else
        echo "Not found: $file"
    fi
}

echo "${GREEN}0: Quit$RESET"
echo "${YELLOW}1: Remove only powercontrol.conf, batterycontrol.conf, fancontrol.conf, and no_turbo.conf from /etc/init (disables turbo on boot).$RESET"
echo "${RED}2: Full Uninstall (remove all files, symlinks, startup files, and user config for powercontrol, batterycontrol, and fancontrol).$RESET"

read -rp "Enter (0-2): " choice

case "$choice" in
    0)
        echo "Uninstall canceled."
        ;;
    1)
        echo "Removing init files..."
        remove_file_with_message /etc/init/no_turbo.conf
        remove_file_with_message /etc/init/batterycontrol.conf
        remove_file_with_message /etc/init/powercontrol.conf
        remove_file_with_message /etc/init/fancontrol.conf
        ;;
    2)
        echo "Stopping background services..."

        sudo initctl stop no_turbo 2>/dev/null
        
        "$INSTALL_DIR/powercontrol" stop
        "$INSTALL_DIR/powercontrol" max_perf_pct 100
        "$INSTALL_DIR/powercontrol" no_turbo 0
        "$INSTALL_DIR/batterycontrol" stop
        "$INSTALL_DIR/fancontrol" stop

        remove_file_with_message /etc/init/no_turbo.conf
        remove_file_with_message /etc/init/batterycontrol.conf
        remove_file_with_message /etc/init/powercontrol.conf
        remove_file_with_message "$INSTALL_DIR/no_turbo.conf"
        remove_file_with_message "$INSTALL_DIR/batterycontrol.conf"
        remove_file_with_message "$INSTALL_DIR/powercontrol.conf"
        remove_file_with_message "$INSTALL_DIR/fancontrol.conf"

        remove_file_with_message /usr/local/bin/ChromeOS_PowerControl_Installer.sh
        remove_file_with_message /usr/local/bin/powercontrol_conf.sh
        remove_file_with_message /usr/local/bin/fancontrol_conf.sh
        remove_file_with_message /usr/local/bin/batterycontrol_conf.sh

        remove_file_with_message /usr/local/bin/powercontrol
        remove_file_with_message /usr/local/bin/batterycontrol
        remove_file_with_message /usr/local/bin/fancontrol

        remove_file_with_message /var/log/powercontrol.log
        remove_file_with_message /var/log/fancontrol.log
        remove_file_with_message /var/log/batterycontrol.log

        remove_file_with_message "$INSTALL_DIR/config.sh"

        sudo rm -f "$INSTALL_DIR/.fancontrol_enabled"
        sudo rm -f "$INSTALL_DIR/.powercontrol_enabled"
        sudo rm -f "$INSTALL_DIR/.batterycontrol_enabled"

        sudo rm -f "$INSTALL_DIR/.fancontrol_pid"
        sudo rm -f "$INSTALL_DIR/.powercontrol_pid"
        sudo rm -f "$INSTALL_DIR/.batterycontrol_pid"
        sudo rm -f "$INSTALL_DIR/.fancontrol_tail_fan_monitor.pid"
        sudo rm -f "$INSTALL_DIR/.powercontrol_tail_fan_monitor.pid"

        remove_file_with_message "$INSTALL_DIR/powercontrol"
        remove_file_with_message "$INSTALL_DIR/fancontrol"
        remove_file_with_message "$INSTALL_DIR/batterycontrol"

        remove_file_with_message "$INSTALL_DIR/LICENSE"
        remove_file_with_message "$INSTALL_DIR/README.md"
        remove_file_with_message "/usr/local/bin/ChromeOS_PowerControl.install_dir"
        remove_file_with_message "$INSTALL_DIR/Uninstall_ChromeOS_PowerControl.sh"

        if [ -d "$INSTALL_DIR" ] && [ -z "$(ls -A "$INSTALL_DIR")" ]; then
            sudo rm -rf "$INSTALL_DIR" && echo "Removed: $INSTALL_DIR"
        else
            echo "Installation directory not found or still contains files: $INSTALL_DIR"
        fi

        echo "${GREEN}Uninstall complete.$RESET"
        ;;
    *)
        echo "${RED}Invalid option.$RESET"
        ;;
esac
