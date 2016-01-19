# prepMac

A simple bash script that takes care of the following things for preparing a machine for exhibition use:

- Disables "Crash Reporting" dialog.
- Disables "Reopen Windows?" shutdown dialog.
- Disables application state restoration dialog.
- Disables Software Update from AppStore.
- Disables sleep.
- Disables screen saver.
- Disables GateKeeper ("unauthorized developer" access.)
- Disables Notification Center
- Enables restart on power failure.

And offers the options to:

- Disable Bluetooth
- Enable Screen Sharing

![Screenshot](https://raw.githubusercontent.com/local-projects/prepMac/screenshots/screen01.png)

## Running
Just run in Terminal with one line by downloading remotely with curl:

	curl -s https://raw.githubusercontent.com/local-projects/prepMac/master/prepMac.sh | sudo bash
	
Or run normally after cloning or downloading with `sudo bash prepMac.sh`.

The script prints its actions to the console and each step may provide relevent feedback depending on your current system configuration (EG: If Notification Center has already been disabled and removed it will say it cannot find it for removal.)
