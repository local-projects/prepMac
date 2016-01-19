#!/bin/bash
now="$(date +"%r")"

printf "\n\n--- BEGINNING MACHINE PREP - $now ---\n\n"

### Dock
printf "\n Cleanup extra Dock icons? [Y / N]\n"
read should_clean_dock

if [$should_clean_dock == 'Y'] || [$should_clean_dock == 'y'] || [$should_clean_dock == 'yes'] || [$should_clean_dock == 'YES']
then
	printf "\n- Emptying, populating, and restarting Dock...\n"
	# Remove all dock items
	defaults write com.apple.dock persistent-apps -array ''
	defaults write com.apple.dock persistent-others -array ''
	# Add defaults: Safari, System Preferences, and Terminal
	defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Safari.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
	defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/System Preferences.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
	defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Utilities/Terminal.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
	### Add any other project apps here ###
	killall Dock
else
	printf "\n- Skipping Dock cleanup.\n"
fi

### Bluetooth
printf "\n Disable Bluetooth? [Y / N]\n"
read should_disable_bluetooth

if [$should_disable_bluetooth == 'Y'] || [$should_disable_bluetooth == 'y'] || [$should_disable_bluetooth == 'yes'] || [$should_disable_bluetooth == 'YES']
then
	printf "\n- Disabling Bluetooth...\n"
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
printf "\n Enable Screen Sharing via Remote Management? [Y / N]\n"
read should_enable_screen_sharing

if [$should_enable_screen_sharing == 'Y'] || [$should_enable_screen_sharing == 'y'] || [$should_enable_screen_sharing == 'yes'] || [$should_enable_screen_sharing == 'YES']
then
printf "\n- Enabling Screen Sharing...\n"
	sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -off -restart -agent -privs -all -allowAccessFor -allUsers
else
	printf "\n- Skipping Screen Sharing.\n"
fi

### Enable Auto Login
printf "\n Enable AUTO LOGIN for the user $USER ? [Y / N]\n"
read should_enable_auto_login

if [$should_enable_auto_login == 'Y'] || [$should_enable_auto_login == 'y'] || [$should_enable_auto_login == 'yes'] || [$should_enable_auto_login == 'YES']
then
printf "\n- Enabling auto login...\n"
	sudo defaults write /Library/Preferences/com.apple.loginwindow "autoLoginUser" $USER
else
	printf "\n- Skipping auto login.\n"
fi

### Crash Reporting
printf "\n- Unloading and disabling crash reporting...\n"
# Disable the dialogue from opening
defaults write com.apple.CrashReporter DialogType none
# Fully disable the diagnostic reporter?
launchctl unload -w /System/Library/LaunchDaemons/com.apple.DiagnosticReportCleanUpDaemon.plist
sudo chmod 000 /System/Library/CoreServices/Problem\ Reporter.app

### "Repoen Windows" dialog
printf "\n- Disabling \"reopen windows?\" dialog...\n"
defaults write com.apple.loginwindow LoginwindowLaunchesRelaunchApps -bool false
defaults write com.apple.loginwindow TALLogoutSavesState -bool false

### Aplication state restoration dialog
printf "\n- Disabling restore application state on crash, globally...\n"
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

### Software Update
printf "\n- Disabling software updates...\n"
defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool false
defaults write /Library/Preferences/com.apple.commerce AutoUpdateRestartRequired -bool false
defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool false
sudo softwareupdate --schedule off

### Sleep
printf "\n- Disabling sleep...\n"
sudo -S systemsetup -setsleep off

### Screen Saver
printf "\n- Disabling screen saver... \n"
defaults -currentHost write com.apple.screensaver idleTime 0

### GateKeeper
printf "\n- Disabling GateKeeper...\n"
spctl --master-disable

### Notification Center
printf "\n- Unloading and disabling notification center...\n"
launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist
killall NotificationCenter

### Restart on Power Failure
printf "\n- Enabling restart on power failure...\n"
systemsetup -setrestartpowerfailure on

now="$(date +"%r")"
printf "\n--- COMPLETED MACHINE PREP - $now ---\n\n"