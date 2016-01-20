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
			read -n 1 -p "" $3
	elif	[ "$1" = "reset" ]
		then
			printf "\e[0m"
	fi
}

### Check if run with SUDO
if [ "$EUID" -ne 0 ]
  then
	  style "antiheader" "Error: prepMac must be run with SUDO priveleges."
	  style "reset"
	  exit
fi

### Starting title
now="$(date +"%r")"
style "title" "BEGINNING MACHINE PREP - $now"

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
defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool false
defaults write /Library/Preferences/com.apple.commerce AutoUpdateRestartRequired -bool false
defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool false
softwareupdate --schedule off

### Sleep ######################################################################
style "header" "Disabling sleep..."
systemsetup -setsleep off
systemsetup -setcomputersleep Off > /dev/null

### Screen Saver ###############################################################
style "header" "Disabling screen saver..."
defaults -currentHost delete com.apple.screensaver
rm ~/Library/Preferences/ByHost/com.apple.screensaver.*
rm ~/Library/Preferences/ByHost/com.apple.ScreenSaver.*
defaults -currentHost write com.apple.screensaver idleTime 0
defaults write /Library/Preferences/com.apple.screensaver loginWindowIdleTime 0

### GateKeeper #################################################################
style "header" "Disabling GateKeeper..."
spctl --master-disable

### Notification Center ########################################################
style "header" "Unloading and disabling notification center..."
launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2> /dev/null
killall NotificationCenter

### Restart on Power Failure ###################################################
style "header" "Enabling restart on power failure..."
systemsetup -setrestartpowerfailure on

### Restart on computer freeze #################################################
style "header" "Enabling restart on computer freeze..."
systemsetup -setrestartfreeze on

### Bluetooth ##################################################################
style "prompt" "Disable Bluetooth? [\e[5my / n\e[25m]: " should_disable_bluetooth
echo
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
echo
if [ "$should_enable_screen_sharing" = "y" ] || [ "$should_enable_screen_sharing" = "Y" ]
	then
		style "header" "Enabling Screen Sharing..."
		/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -off -restart -agent -privs -all -allowAccessFor -specifiedUsers
	else
		style "antiheader" "Skipping Screen Sharing."
fi

### Enable Auto Login ##########################################################
echo
printf "\e[0mNOTE: To enable AUTO LOGIN please use System Preferences\n"

### Ending title
now="$(date +"%r")"
style "title" "COMPLETED MACHINE PREP - $now"