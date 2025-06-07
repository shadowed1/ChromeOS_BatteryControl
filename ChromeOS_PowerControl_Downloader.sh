#!/bin/bash
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)
echo ""
echo "${RED}Beta$RESET"
echo ""
echo "${CYAN}Downloading to: /home/chronos/ChromeOS_PowerControl_Installer.sh $RESET"
curl -L https://raw.githubusercontent.com/shadowed1/ChromeOS_PowerControl/beta/ChromeOS_PowerControl_Installer.sh -o /home/chronos/ChromeOS_PowerControl_Installer.sh
echo "${GREEN}${BOLD}Download complete. You can run the installer with VT-2 or enable sudo in crosh after moving it to an executable location:$RESET"
echo ""
echo "${YELLOW}sudo mv /home/chronos/ChromeOS_PowerControl_Installer.sh /usr/local/bin"
echo ""
echo "sudo bash /usr/local/bin/ChromeOS_PowerControl_Installer.sh"
echo "$RESET"
