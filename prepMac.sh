#!/bin/bash

#################################################
#   prepMac.sh - 2016                           #
#   https://github.com/local-projects/prepMac   #
#################################################

### Style formatting function
function style {
	if		[ "$1" = "title" ]
		then
			printf "\n\n\e[0m\e[1m\e[7m --- $2 --- \e[0m\n\n"
	elif	[ "$1" = "header" ]
		then
			printf "\n\e[0m\e[36m\e[4m$2\e[0m\n\e[2m" # Leaves next lines DIM
	elif	[ "$1" = "antiheader" ]
		then
			printf "\n\e[0m\e[31m\e[4m$2\e[0m\n\e[2m" # Leaves next lines DIM
	elif	[ "$1" = "prompt" ]
		then
			echo
			printf "\e[0m\e[35m$2\e[0m"
			read -p "" $3
	elif	[ "$1" = "reset" ]
		then
			printf "\e[0m"
	fi
}

### Starting title
now="$(date +"%r")"

style "title" "BEGINNING MACHINE PREP - $now"

### Get password for SUDO commands.
if [ "$EUID" -ne 0 ]
  then
  	style "antiheader" "Most of prepMac.sh needs elevated access- please enter your SUDO password"
  	style "reset"
		sudo -v
		while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
fi

### Crash Reporting ############################################################
style "header" "Unloading and disabling crash reporting..."
# Disable the dialogue from opening
defaults write com.apple.CrashReporter DialogType none
# Fully disable the diagnostic reporter?
launchctl unload -w /System/Library/LaunchDaemons/com.apple.DiagnosticReportCleanUpDaemon.plist
chmod 000 /System/Library/CoreServices/Problem\ Reporter.app

### "Repoen Windows" dialog ####################################################
style "header" "Disabling\"reopen windows?\" dialog..."
defaults write com.apple.loginwindow LoginwindowLaunchesRelaunchApps -bool false
defaults write com.apple.loginwindow TALLogoutSavesState -bool false

### Aplication state restoration dialog ########################################
style "header" "Disabling restore application state on crash, globally..."
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -boolean false # Seems to need "-boolean" ?

### Software Update ############################################################
style "header" "Disabling software updates..."
sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool false
sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdateRestartRequired -bool false
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool false
sudo softwareupdate --schedule off

### Sleep ######################################################################
style "header" "Disabling sleep..."
sudo systemsetup -setsleep off
sudo systemsetup -setcomputersleep Off > /dev/null

### Screen Saver ###############################################################
style "header" "Disabling screen saver..."
rm ~/Library/Preferences/ByHost/com.apple.screensaver.*
rm ~/Library/Preferences/ByHost/com.apple.ScreenSaver.*
defaults -currentHost delete com.apple.screensaver
defaults -currentHost write com.apple.screensaver idleTime 0
sudo defaults write /Library/Preferences/com.apple.screensaver loginWindowIdleTime 0

### TextEdit defaults ##########################################################
style "header" "Making TextEdit default to PlainText with UTF-8 encoding..."
defaults write com.apple.TextEdit RichText -int 0
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

### GateKeeper #################################################################
style "header" "Disabling GateKeeper..."
sudo spctl --master-disable

### Notification Center ########################################################
style "header" "Unloading and disabling notification center..."
launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2> /dev/null
killall NotificationCenter

### Restart on Power Failure ###################################################
style "header" "Enabling restart on power failure..."
sudo systemsetup -setrestartpowerfailure on

### Restart on computer freeze #################################################
style "header" "Enabling restart on computer freeze..."
sudo systemsetup -setrestartfreeze on

### Bluetooth ##################################################################
style "prompt" "Disable Bluetooth? [\e[5my / n\e[25m]: " should_disable_bluetooth

if [ "$should_disable_bluetooth" = "y" ] || [ "$should_disable_bluetooth" = "Y" ]
	then
		style "header" "Disabling Bluetooth..."
		# Set bluetooth pref to off
		defaults write /Library/Preferences/com.apple.Bluetooth.plist ControllerPowerState 0
		# Kill the bluetooth server process
		killall blued
		# Unload the daemon
		launchctl unload /System/Library/LaunchDaemons/com.apple.blued.plist
	else
		style "antiheader" "Skipping Bluetooth changes."
fi

### Screen Sharing - NOTE: allows access for all users #########################
style "prompt" "Enable Screen Sharing for all users via Remote Management? [\e[5my / n\e[25m]: " should_enable_screen_sharing

if [ "$should_enable_screen_sharing" = "y" ] || [ "$should_enable_screen_sharing" = "Y" ]
	then
		style "header" "Enabling Screen Sharing..."
		sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -off -restart -agent -privs -all -allowAccessFor -specifiedUsers
	else
		style "antiheader" "Skipping Screen Sharing."
fi

### Dock #######################################################################
style "prompt" "Cleanup extra Dock icons? [y / n]: " should_clean_dock

if [ "$should_clean_dock" = "y" ] || [ "$should_clean_dock" = "Y" ]
	then
		style "header" "Emptying, populating, and restarting Dock..."
		# Remove all dock items
		defaults write com.apple.dock persistent-apps -array ''
		defaults write com.apple.dock persistent-others -array ''
		# Add defaults: Safari, System Preferences, and Terminal
		defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Safari.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
		defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/System Preferences.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
		defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Utilities/Terminal.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
		### Add any other project apps here ###
		style "prompt" "Add project's app to dock? [y / n]: " should_add_custom_app
		if [ "$should_add_custom_app" = "y" ] || [ "$should_add_custom_app" = "Y" ]
			then
				style "prompt" "Enter app location (ex : /Applications/Utilities/Terminal.app) and press return: " custom_app_location
				style "header" "Adding $custom_app_location to the dock..."
				defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>'$custom_app_location'</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
		fi
		killall Dock
	else
		style "antiheader" "Skipping Dock cleanup."
fi

### Additional step helpful info
style "reset"
printf "\e[1m\n\nADITIONAL STEPS:\n"
style "reset"
printf "▸ To enable AUTO LOGIN please use \e[1mSystem Preferences > Security & Privacy\e[0m.\n"
printf "▸ For multi-screen setup you may need to go to:\n\t\e[1mSystem Preferences > Mission Control\e[0m and disable \e[1mDisplays have separate Spaces\e[0m.\n"
style "reset"

### Ending title
now="$(date +"%r")"
style "title" "COMPLETED MACHINE PREP - $now"
style "reset"