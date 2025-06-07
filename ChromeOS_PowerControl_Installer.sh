#!/bin/bash
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)
detect_cpu_type() {
    CPU_VENDOR=$(grep -m1 'vendor_id' /proc/cpuinfo | awk '{print $3}' || echo "unknown")
    IS_INTEL=0
    IS_AMD=0
    IS_ARM=0
    case "$CPU_VENDOR" in
        GenuineIntel)
            IS_INTEL=1
            PERF_PATH="/sys/devices/system/cpu/intel_pstate/max_perf_pct"
            TURBO_PATH="/sys/devices/system/cpu/intel_pstate/no_turbo"
            ;;
        AuthenticAMD)
            IS_AMD=1
            if [ -f "/sys/devices/system/cpu/amd_pstate/max_perf_pct" ]; then
                PERF_PATH="/sys/devices/system/cpu/amd_pstate/max_perf_pct"
            else
                PERF_PATH="/sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq"
            fi
            TURBO_PATH=""
            ;;
        *)
            IS_ARM=1
            PERF_PATH="/sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq"
            TURBO_PATH=""
            ;;
    esac
}
echo ""
echo "${RED}${BOLD}Enabling sudo in crosh or run in VT-2 is required for this to download successfully.$RESET"
echo ""
read -rp "${GREEN}${BOLD}Enter Install Path - leave blank for: /usr/local/bin/ChromeOS_PowerControl:$RESET" INSTALL_DIR
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin/ChromeOS_PowerControl}"
INSTALL_DIR="${INSTALL_DIR%/}"

echo ""
sudo mkdir -p "$INSTALL_DIR"

declare -a files=("powercontrol" "batterycontrol" "fancontrol" "Uninstall_ChromeOS_PowerControl.sh" "LICENSE" "README.md" "no_turbo.conf" "batterycontrol.conf" "powercontrol.conf" "fancontrol.conf" "config.sh")
for file in "${files[@]}"; do
    curl -L "https://raw.githubusercontent.com/shadowed1/ChromeOS_PowerControl/beta/$file" -o "$INSTALL_DIR/$file"
    echo "$INSTALL_DIR/$file downloaded."
    echo ""
done

curl -L https://raw.githubusercontent.com/shadowed1/ChromeOS_PowerControl/beta/powercontrol_conf.sh -o /usr/local/bin/powercontrol_conf.sh
echo " /usr/local/bin/ChromeOS_PowerControl/powercontrol_conf.sh downloaded."
echo ""
curl -L https://raw.githubusercontent.com/shadowed1/ChromeOS_PowerControl/beta/batterycontrol_conf.sh -o /usr/local/bin/batterycontrol_conf.sh
echo " /usr/local/bin/ChromeOS_PowerControl/batterycontrol_conf.sh downloaded."
echo ""
curl -L https://raw.githubusercontent.com/shadowed1/ChromeOS_PowerControl/beta/fancontrol_conf.sh -o /usr/local/bin/fancontrol_conf.sh
echo " /usr/local/bin/ChromeOS_PowerControl/fancontrol_conf.sh downloaded."
echo ""

detect_cpu_type
echo "${CYAN}Detected CPU Vendor: $CPU_VENDOR"
echo "PERF_PATH: $PERF_PATH"
echo "TURBO_PATH: $TURBO_PATH"
echo "$INSTALL_DIR" | sudo tee /usr/local/bin/ChromeOS_PowerControl.install_dir > /dev/null
echo "$RESET"
sudo chmod +x "$INSTALL_DIR/powercontrol" "$INSTALL_DIR/batterycontrol" "$INSTALL_DIR/fancontrol" "$INSTALL_DIR/Uninstall_ChromeOS_PowerControl.sh" "$INSTALL_DIR/config.sh"
sudo touch "$INSTALL_DIR/.batterycontrol_enabled" "$INSTALL_DIR/.powercontrol_enabled" "$INSTALL_DIR/.fancontrol_enabled"
sudo touch "$INSTALL_DIR/.fan_curve_pid" "$INSTALL_DIR/.fancontrol_tail_fan_monitor.pid" "$INSTALL_DIR/.batterycontrol_pid" "$INSTALL_DIR/.powercontrol_tail_fan_monitor.pid" "$INSTALL_DIR/.powercontrol_pid"

LOG_DIR="/var/log"
CONFIG_FILE="$INSTALL_DIR/config.sh"
sudo touch "$LOG_DIR/powercontrol.log" "$LOG_DIR/batterycontrol.log" "$LOG_DIR/fancontrol.log"
sudo chmod 644 "$LOG_DIR/powercontrol.log" "$LOG_DIR/batterycontrol.log" "$LOG_DIR/fancontrol.log"
sudo chmod +x /usr/local/bin/powercontrol_conf.sh
sudo chmod +x /usr/local/bin/fancontrol_conf.sh
sudo chmod +x /usr/local/bin/batterycontrol_conf.sh
echo "${YELLOW}Log files for PowerControl, BatteryControl, and FanControl are stored in /var/log/$RESET"
echo ""
USER_HOME="/home/chronos"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Creating config at $CONFIG_FILE"
    echo "CHARGE_MAX=77" >> "$CONFIG_FILE"
    echo "CHARGE_MIN=74" >> "$CONFIG_FILE"
    echo "MAX_TEMP=86" >> "$CONFIG_FILE"
    echo "MAX_PERF_PCT=100" >> "$CONFIG_FILE"
    echo "MIN_TEMP=60" >> "$CONFIG_FILE"
    echo "MIN_PERF_PCT=50" >> "$CONFIG_FILE"
    echo "FAN_MIN_TEMP=48" >> "$CONFIG_FILE"
    echo "FAN_MAX_TEMP=81" >> "$CONFIG_FILE"
    echo "FAN_MIN=0" >> "$CONFIG_FILE"
    echo "FAN_MAX=100" >> "$CONFIG_FILE"
    echo "FAN_SLEEP_INTERVAL=3" >> "$CONFIG_FILE"
    echo "FAN_STEP_UP=20" >> "$CONFIG_FILE"
    echo "FAN_STEP_DOWN=1" >> "$CONFIG_FILE"
    echo "Config created."
    echo "Settings stored at: $CONFIG_FILE"
else
    echo "Settings stored at: $CONFIG_FILE"
fi

echo "PERF_PATH=$PERF_PATH" >> "$CONFIG_FILE"
echo "TURBO_PATH=$TURBO_PATH" >> "$CONFIG_FILE"
echo "IS_AMD=$IS_AMD" >> "$CONFIG_FILE"
echo "IS_INTEL=$IS_INTEL" >> "$CONFIG_FILE"
echo "IS_ARM=$IS_ARM" >> "$CONFIG_FILE"
echo ""

echo "${GREEN}${BOLD}Installing to: $INSTALL_DIR $RESET"

if [ "$IS_INTEL" -eq 1 ]; then
    read -rp "${BOLD}${CYAN}Do you want Intel Turbo Boost disabled on boot? (y/n):$RESET " move_no_turbo
    if [[ "$move_no_turbo" =~ ^[Yy]$ ]]; then
        sudo cp "$INSTALL_DIR/no_turbo.conf" /etc/init/
        echo "Turbo Boost will be disabled on restart."
        echo ""
    else
        echo "Turbo Boost will remain enabled."
        echo ""
    fi

    read -rp "${BOLD}${CYAN}Do you want to disable Intel Turbo Boost now? (y/n):$RESET " run_no_turbo
    if [[ "$run_no_turbo" =~ ^[Yy]$ ]]; then
        echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo > /dev/null
        echo "Turbo Boost disabled immediately."
        echo ""
    else
        echo "Turbo Boost remains enabled."
        echo ""
    fi
else
    echo "This is not an Intel CPU, skipping Turbo Boost options."
    echo ""
fi

read -rp "${BOLD}${YELLOW}Do you want to create global commands 'powercontrol', 'batterycontrol', and 'fancontrol'? (y/n):$RESET " link_cmd
if [[ "$link_cmd" =~ ^[Yy]$ ]]; then
    sudo ln -sf "$INSTALL_DIR/powercontrol" /usr/local/bin/powercontrol
    sudo ln -sf "$INSTALL_DIR/batterycontrol" /usr/local/bin/batterycontrol
    sudo ln -sf "$INSTALL_DIR/fancontrol" /usr/local/bin/fancontrol
    echo "Global commands created for 'powercontrol', 'batterycontrol', and 'fancontrol'."
    echo ""
else
    echo "Skipped creating global commands."
    echo ""
fi

enable_component_on_boot() {
    local component="$1"
    local config_file="$2"
    read -rp "${YELLOW}Do you want $component enabled on boot? (y/n):$RESET " move_config
    if [[ "$move_config" =~ ^[Yy]$ ]]; then
        sudo cp "$config_file" /etc/init/
        echo "$component will start on boot."
        echo ""
    else
        echo "$component must be started manually on boot."
        echo ""
    fi
}

enable_component_on_boot "BatteryControl" "$INSTALL_DIR/batterycontrol.conf"
enable_component_on_boot "PowerControl" "$INSTALL_DIR/powercontrol.conf"
enable_component_on_boot "FanControl" "$INSTALL_DIR/fancontrol.conf"

start_component_now() {
    local component="$1"
    local command="$2"
    read -rp "${BOLD}${GREEN}Do you want to start $component now in the background? (y/n): $RESET " start_now
    if [[ "$start_now" =~ ^[Yy]$ ]]; then
        sudo "$command" start
        echo "${BOLD}$component started in the background. $RESET"
        echo ""
    else
        echo "You can run it later with: sudo $command start"
        echo ""
    fi
}

start_component_now "BatteryControl" "$INSTALL_DIR/batterycontrol"
start_component_now "PowerControl" "$INSTALL_DIR/powercontrol"
start_component_now "FanControl" "$INSTALL_DIR/fancontrol"

echo ""
echo "           ${RED}████████████${RESET}           "
echo "       ${RED}████${RESET}        ${RED}████${RESET}       "
echo "     ${RED}██${RESET}              ${YELLOW}██${RESET}     "
echo "   ${GREEN}██${RESET}     ${CYAN}██████${RESET}     ${YELLOW}██${RESET}   "
echo "  ${GREEN}██${RESET}     ${CYAN}████████${RESET}     ${YELLOW}██${RESET}  "
echo "  ${GREEN}██${RESET}     ${CYAN}████████${RESET}     ${YELLOW}██${RESET}  "
echo "   ${GREEN}██${RESET}     ${CYAN}██████${RESET}     ${YELLOW}██${RESET}   "
echo "     ${GREEN}██${RESET}              ${YELLOW}██${RESET}     "
echo "       ${GREEN}████${RESET}        ${YELLOW}████${RESET}       "
echo "           ${GREEN}████████████${RESET}           "
echo ""
echo "        ${BOLD}${GREEN}Chrome${RESET}${BOLD}${RED}OS${RESET}${BOLD}${YELLOW}_${RESET}${BOLD}${CYAN}PowerControl${RESET}"
echo ""

echo ""
echo "${BOLD}Commands with examples: $RESET"
echo ""
echo "${CYAN}# PowerControl:"
echo "sudo powercontrol                     # Show status"
echo "sudo powercontrol start               # Throttle CPU based on temperature curve"
echo "sudo powercontrol stop                # Restore default CPU settings"
echo "sudo powercontrol no_turbo 1          # Disable turbo boost"
echo "sudo powercontrol max_perf_pct 75     # Set max performance percentage"
echo "sudo powercontrol min_perf_pct 50     # Set minimum performance at max temp"
echo "sudo powercontrol max_temp 86         # Max temperature threshold"
echo "sudo powercontrol min_temp 60         # Min temperature threshold"
echo "sudo powercontrol monitor             # Live temperature monitoring"
echo "sudo powercontrol help                # Help menu"
echo "$RESET"
echo "${GREEN}# BatteryControl:"
echo "sudo batterycontrol                   # Check BatteryControl status"
echo "sudo batterycontrol start             # Start BatteryControl"
echo "sudo batterycontrol stop              # Stop BatteryControl"
echo "sudo batterycontrol set 80 75         # Set max/min battery charge thresholds"
echo "sudo batterycontrol help              # Help menu"
echo "$RESET"
echo "${YELLOW}#FanControl:"
echo "sudo fancontrol                       # Show fan status"
echo "sudo fancontrol start                 # Start FanControl"
echo "sudo fancontrol stop                  # Stop FanControl"
echo "sudo fancontrol min_temp 50           # Min temp threshold"
echo "sudo fancontrol max_temp 90           # Max temp threshold"
echo "sudo fancontrol min_fan 0             # Min fan speed %"
echo "sudo fancontrol max_fan 100           # Max fan speed %"
echo "sudo fancontrol stepup 20             # Fan step-up %"
echo "sudo fancontrol stepdown 1            # Fan step-down %" 
echo "sudo fancontrol help                  # Help menu"
echo "$RESET"
echo "${RED}${BOLD}sudo powercontrol uninstall           # Run uninstaller$RESET"
echo "${RED}Alternative:$RESET"
echo "${RED}${BOLD}sudo bash "$INSTALL_DIR/Uninstall_ChromeOS_PowerControl.sh" $RESET"
