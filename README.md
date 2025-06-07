# **ChromeOS PowerControl**

![Logo](https://i.imgur.com/yMQmKrF.png)


# Beta: Custom Install location, logs moved to /var/log/, added /etc/init startup commands, unified config file, time stamps, bug fixes, and more. 
## Requires Developer Mode - Supports AMD, ARM, and Intel.
## - Control battery charging limit instead of relying on Adaptive Charging to maximize battery longevity. 
## - Control CPU clock speed boost in relation to temperature; enabling lower temperatures under load and longer battery life.
## - Control Fan speed in relation to temperature with built-in hysteresis and 0% RPM mode. 
### - Features global commands for ease of use, config files that save settings, and an uninstaller to clean up after itself. 
### - Optionally have BatteryControl, PowerControl, FanControl start on boot; as well as disabling Turbo Boost on boot if user has rootfs verification disabled.

### __How to Install:__

- Open crosh shell and run:

`bash <(curl -s "https://raw.githubusercontent.com/shadowed1/ChromeOS_PowerControl/beta/ChromeOS_PowerControl_Downloader.sh?$(date +%s)")`

- The installer will be placed: `~/tmp/ChromeOS_PowerControl/ChromeOS_PowerControl_Installer.sh`

- In *VT-2* or *crosh shell with sudo enabled* run:
  
  `sudo mv ~/tmp/ChromeOS_PowerControl_Installer.sh /usr/local/bin`
- `sudo bash /usr/local/bin/ChromeOS_PowerControl_Installer.sh`

- Installer has prompts to customize installation.
- PowerControl, BatteryControl, and FanControl can run in the background and can be adjusted in real-time.

### __Commands with examples:__

- `sudo powercontrol                     # Show status`
- `sudo powercontrol start               # Throttle CPU based on temperature curve`
- `sudo powercontrol stop                # Default CPU temperature curve. no_turbo setting restored.`
- `sudo powercontrol no_turbo 1          # 0 is default (Intel Only) Turbo Boost On behavior.`
- `sudo powercontrol max_perf_pct 75     # 10 to 100%. 100 is default behavior; can be run standalone.`
- `sudo powercontrol min_perf_pct 50     # Minimum clockspeed CPU can reach at max_temp.`
- `sudo powercontrol max_temp 86         # Threshold when min_perf_pct is reached. Limit is 90 Celcius.`
- `sudo powercontrol min_temp 60         # Threshold when max_perf_pct is reached.`
- `sudo powercontrol monitor             # Updates log real-time in terminal window; run again to toggle off. `
- `sudo powercontrol startup 1`
- `sudo powercontrol help                # Show list of commands. `
  
----------------------------------------------------------------------------------------------

- `sudo batterycontrol start               # starts batterycontrol`
- `sudo batterycontrol stop                # stops batterycontrol`
- `sudo batterycontrol status              # shows status. Leaving it blank also works`
- `sudo batterycontrol set 80 75           # 80 is when charging stops; 75 is when char.ging may begin`
- `sudo batterycontrol help                # Show list of commands`

----------------------------------------------------------------------------------------------
- `sudo fancontrol                        # Show status`
- `sudo fancontrol start                  # starts fancontrol`
- `sudo fancontrol stop                   # stops fancontrol and restores default fan behavior.`
- `sudo fancontrol monitor                # Updates log real-time in terminal window; run again to toggle off.` 
- `sudo fancontrol min_temp 48            # Threshold in C for min_fan speed is met.`
- `sudo fancontrol max_temp 82            # Threshold in C for max_fan speed is met. 90 Celcius is max.`
- `sudo fancontrol min_fan 0              # % in fan speed when temperature is at or below min_temp.`
- `sudo fancontrol max_fan 100            # % in fan speed when temperature is at or below max_temp.`
- `sudo fancontrol stepup 20              # % in fan granularity when temperature is climbing.`
- `sudo fancontrol stepdown 1             # % in fan granularity when temperature is falling.`
- `sudo fancontrol help                   #  Show list of commands. `

----------------------------------------------------------------------------------------------

- `sudo powercontrol uninstall            # Global uninstaller that will clean up after itself`
- Alternative uninstall method: `sudo /usr/local/bin/ChromeOS_PowerControl/Uninstall_ChromeOS_PowerControl.sh`

### __How It Works:__

__PowerControl:__
- Uses ARM, AMD, and Intel's max_perf_pct for easy user control.
- Pairs user adjustable max_perf_pct and thermal0 temp sensor to create a user adjustable clockspeed-temperature curve. 
- If $min_temp threshold is below a certain point, the CPU will be able to reach max_perf_pct of its speed.
- The closer the CPU approaches $max_temp, the closer it is to min_perf_pct.

__BatteryControl:__
- Uses ectool's chargecontrol to toggle between normal or idle.
- Check's CROS_USBPD_CHARGER0/online to see if it is plugged in or not
- Check's BAT0/capacity to measure when to control chargecontrol.
- ChromeOS reports slightly higher values than what BatteryControl sets the charge limit to.

__FanControl:__
- Uses ectool's fanduty control and autofanctrl for manual and automatic control.
- Pairs fanduty with thermal0 temperature sensor for a user adjustable fan-temperature curve.
- Uses hysteresis formula to attempt a better sounding and performing fan curve than the OEM provides. 
- Uses a kickstart mechanism when fan leaves 0% to enable zero RPM mode for any fan type.

### __Bonus:__
- To disable rootfs verification open VT-2, login as root, and run:
 `/usr/libexec/debugd/helpers/dev_features_rootfs_verification`
- Enable sudo for crosh: `https://gist.github.com/velzie/a5088c9ade6ec4d35435b9826b45d7a3`

###  __Credits:__

- Thanks to WesBosch for helping me learn to make an installer:
  https://github.com/WesBosch
  
- Thanks to DennyL on ChromeOS discord for showing me how to enable sudo on crosh, test out PowerControl, and provide many great suggestions. 


