#!/bin/bash
now="$(date +"%r")"

printf "\n\n\e[1m\e[7m --- BEGINNING MACHINE PREP - $now --- \e[0m\n\n"

### Crash Reporting
printf "\n\e[36m\e[4mUnloading and disabling crash reporting...\e[0m\n\e[2m"
# Disable the dialogue from opening
defaults write com.apple.CrashReporter DialogType none
# Fully disable the diagnostic reporter?
launchctl unload -w /System/Library/LaunchDaemons/com.apple.DiagnosticReportCleanUpDaemon.plist
sudo chmod 000 /System/Library/CoreServices/Problem\ Reporter.app

### "Repoen Windows" dialog
printf "\n\e[0m\e[36m\e[4mDisabling\"reopen windows?\" dialog...\e[0m\n\e[2m"
defaults write com.apple.loginwindow LoginwindowLaunchesRelaunchApps -bool false
defaults write com.apple.loginwindow TALLogoutSavesState -bool false

### Aplication state restoration dialog
printf "\n\e[0m\e[36m\e[4mDisabling restore application state on crash, globally...\e[0m\n\e[2m"
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

### Software Update
printf "\n\e[0m\e[36m\e[4mDisabling software updates...\e[0m\n\e[2m"
defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool false
defaults write /Library/Preferences/com.apple.commerce AutoUpdateRestartRequired -bool false
defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool false
sudo softwareupdate --schedule off

### Sleep
printf "\n\e[0m\e[36m\e[4mDisabling sleep...\e[0m \n\e[2m"
sudo -S systemsetup -setsleep off

### Screen Saver
printf "\n\e[0m\e[36m\e[4mDisabling screen saver...\e[0m \n\e[2m"
defaults -currentHost write com.apple.screensaver idleTime 0

### GateKeeper
printf "\n\e[0m\e[36m\e[4mDisabling GateKeeper...\e[0m\n\e[2m"
spctl --master-disable

### Notification Center
printf "\n\e[0m\e[36m\e[4mUnloading and disabling notification center...\e[0m\n\e[2m"
launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist
killall NotificationCenter

### Restart on Power Failure
printf "\n\e[0m\e[36m\e[4mEnabling restart on power failure...\e[0m\n\e[2m"
systemsetup -setrestartpowerfailure on
printf "\e[0m"

### Bluetooth
echo
printf "\e[0m"
read -n 1 -p "Disable Bluetooth? [y / n]: " should_disable_bluetooth
echo
if [ "$should_disable_bluetooth" = "y" ] || [ "$should_disable_bluetooth" = "Y" ]
	then
		printf "\n\e[0m\e[36m\e[4mDisabling Bluetooth...\e[0m\n\e[2m"
		# Set bluetooth pref to off
		defaults write /Library/Preferences/com.apple.Bluetooth.plist ControllerPowerState 0
		# Kill the bluetooth server process	
		killall blued
		# Unload the daemon
		launchctl unload /System/Library/LaunchDaemons/com.apple.blued.plist
	else
		printf "\n- Skipping Bluetooth changes.\n"
fi

### Screen Sharing - NOTE: allows access for all users
echo
printf "\e[0m"
read -n 1 -p "Enable Screen Sharing via Remote Management? [y / n]: " should_enable_screen_sharing
echo
if [ "$should_enable_screen_sharing" = "y" ] || [ "$should_enable_screen_sharing" = "Y" ]
	then
		printf "\n\e[0m\e[36m\e[4mEnabling Screen Sharing...\e[0m\n\e[2m"
		sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -off -restart -agent -privs -all -allowAccessFor -allUsers
	else
		printf "\n- Skipping Screen Sharing.\n"
fi

### Enable Auto Login
echo
printf "\e[0mTo enable AUTO LOGIN please use System Preferences\n"

now="$(date +"%r")"
printf "\n\e[0m\e[1m\e[5m\e[7m --- COMPLETED MACHINE PREP - $now --- \e[0m\n\n"