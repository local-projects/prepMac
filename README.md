# prepMac

A bash script that takes care of the following things for preparing a machine-

- Empties Dock and adds Safari, System Preferences, and Terminal icons.
- Disables "Crash Reporting" dialog.
- Disables "Reopen Windows?" shutdown dialog.
- Disables application state restoration dialog.
- Disables Software Update from AppStore.
- Disables sleep.
- Disables GateKeeper ("unauthorized developer" access.)
- Disables Notification Center
- Enables restart on power failure.

## Running
Copy the scipt or clone the repo and run with SUDO access

	sudo bash prepMac.sh
	
The script prints it's actions to the console and each step may provide relevent feedback depending on your current system configuration (EG: If Notification Center has already been disabled and removed it will say it cannot find it for removal.)

## Customizing
Your software can be added to the Dock by adding the following in the dock section before `killall Dock` and replacing the YOUR APP.app string:
	
	defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/YOUR APP.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'