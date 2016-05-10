# prepMac

![Screenshot](https://raw.githubusercontent.com/local-projects/prepMac/screenshots/screen01.png)

A simple bash script that takes care of the following things for preparing a machine for exhibition use:

- Enables auto-restart on system freeze
- Disables "Crash Reporting" dialog
- Disables "Reopen Windows?" shutdown dialog
- Disables application state restoration dialog
- Disables Software Update from AppStore
- Disables sleep
- Disables screen saver
- Makes TextEdit default to Plain Text
- Replaces desktop image with dark grey
- Disables GateKeeper ("unauthorized developer" access.)
- Disables Notification Center
- Disables the Bluetooth Setup Assistant window
- Enables restart on power failure and computer freeze

And offers the options to:

- Reboot the machine every day at 4:00AM
- Disable Bluetooth
- Enable Screen Sharing
- Enable Remote Access (SSH)
- Clean up Dock and add your app by location

## Running

Download and run by copying the following into Terminal:

```sh
curl -O https://raw.githubusercontent.com/local-projects/prepMac/master/prepMac.sh; source prepMac.sh; rm prepMac.sh;
```

__NOTE:__ Run with the flag `-defaults` to execute without optional prompts. These defaults will NOT disable Bluetooth and NOT enable the 4:00AM system restart.

Many of the operations inside of prepMac require sudo privelege. You will be prompted when running if needed.

The script prints its actions to the console and each step may provide relevent feedback depending on your current system configuration (EG: If Notification Center has already been disabled and removed it will say it cannot find it for removal.)
