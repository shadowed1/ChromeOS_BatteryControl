#!/bin/bash
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)
echo ""
echo ""
echo ""
echo "           ${RED}████████████${RESET}           "
echo "       ${RED}████${RESET}        ${RED}████${RESET}       "
echo "     ${RED}██${RESET}              ${YELLOW}██${RESET}     "
echo "   ${GREEN}██${RESET}     ${BLUE}██████${RESET}     ${YELLOW}██${RESET}   "
echo "  ${GREEN}██${RESET}     ${BLUE}████████${RESET}     ${YELLOW}██${RESET}  "
echo "  ${GREEN}██${RESET}     ${BLUE}████████${RESET}     ${YELLOW}██${RESET}  "
echo "   ${GREEN}██${RESET}     ${BLUE}██████${RESET}     ${YELLOW}██${RESET}   "
echo "     ${GREEN}██${RESET}              ${YELLOW}██${RESET}     "
echo "       ${GREEN}████${RESET}        ${YELLOW}████${RESET}       "
echo "           ${GREEN}████████████${RESET}           "
echo ""
echo "     ${BOLD}${GREEN}Chrome${RESET}${BOLD}${RED}OS${RESET}${BOLD}${YELLOW}_${RESET}${BOLD}${BLUE}PowerControl${RESET}"
echo ""
echo "Features:${CYAN}"
echo ""
echo "PowerControl: Control CPU clockspeed in relation to temperature; enabling lower temperatures under load and longer battery life.${RESET}${GREEN}"
echo "BatteryControl: Control battery charging limit instead of relying on Adaptive Charging to maximize battery longevity.${RESET}${YELLOW}"
echo "FanControl: Control fan curve in relation to temperature with built-in hysteresis and 0% RPM mode.${RESET}${MAGENTA}"
echo "GPUControl: Control GPU clockspeed below its default maximum; enabling lower temperatures and longer battery life when rendering 3D content.${RESET}${BLUE}"
echo "SleepControl: Control how long ChromeOS can remain idle before sleep; irrespective of system sleep settings.${RESET}"
echo ""
echo "${CYAN}${BOLD}Downloading to: /home/chronos/ChromeOS_PowerControl_Installer.sh $RESET"
curl -L https://raw.githubusercontent.com/shadowed1/ChromeOS_PowerControl/unstable/ChromeOS_PowerControl_Installer.sh -o /home/chronos/ChromeOS_PowerControl_Installer.sh
echo "${GREEN}${BOLD}Download complete. Run the installer with VT-2 or enable sudo in crosh."
echo "Move it to an executable location or run these commands with VT-2:$RESET"
echo ""
echo "${BOLD}sudo mkdir -p /usr/local/bin"
echo ""
echo "sudo mv /home/chronos/ChromeOS_PowerControl_Installer.sh /usr/local/bin"
echo ""
echo "sudo bash /usr/local/bin/ChromeOS_PowerControl_Installer.sh"
echo "$RESET"
echo ""
