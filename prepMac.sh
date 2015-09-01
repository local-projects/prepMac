#!/bin/bash

printf "\n\n--- BEGIN MACHINE PREP ---\n\n"

# Dock
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

# Crash Reporting
printf "\n- Unloading and disabling crash reporting...\n"
launchctl unload -w /System/Library/LaunchDaemons/com.apple.DiagnosticReportCleanUpDaemon.plist
defaults write com.apple.CrashReporter DialogType none

# "Repoen Windows" dialog
printf "\n- Disabling \"reopen windows?\" dialog...\n"
defaults write com.apple.loginwindow LoginwindowLaunchesRelaunchApps -bool false
defaults write com.apple.loginwindow TALLogoutSavesState -bool false

# Aplication state restoration dialog
printf "\n- Disabling restore application state on crash, globally...\n"
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool 'false'

# Software Update
printf "\n- Disabling software updates...\n"
sudo softwareupdate --schedule off

# Sleep
printf "\n- Disabling sleep...\n"
sudo -S systemsetup -setsleep off

# GateKeeper
printf "\n- Disabling GateKeeper...\n"
spctl --master-disable

# Notification Center
printf "\n- Unloading and disabling notification center...\n"
launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist
killall NotificationCenter

#Restart on Power Failure
printf "\n- Enabling restart on power failure...\n"
systemsetup -setrestartpowerfailure on

printf "\n--- DONE ---\n\n"