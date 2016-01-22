# prepMac

![Screenshot](https://raw.githubusercontent.com/local-projects/prepMac/screenshots/screen01.png)

A simple bash script that takes care of the following things for preparing a machine for exhibition use:

- Disables "Crash Reporting" dialog
- Disables "Reopen Windows?" shutdown dialog
- Disables application state restoration dialog
- Disables Software Update from AppStore
- Disables sleep
- Disables screen saver
- Makes TextEdit default to Plain Text
- Disables GateKeeper ("unauthorized developer" access.)
- Disables Notification Center
- Enables restart on power failure and computer freeze

And offers the options to:

- Disable Bluetooth
- Enable Screen Sharing
- Clean up Dock and add your app by location

## Running

Download and run with a single line:

```
wget https://raw.githubusercontent.com/local-projects/prepMac/master/prepMac.sh; bash prepMac.sh; rm prepMac.sh;
```

Many of the operations inside of prepMac require sudo privelege. You will be prompted when running if needed.

The script prints its actions to the console and each step may provide relevent feedback depending on your current system configuration (EG: If Notification Center has already been disabled and removed it will say it cannot find it for removal.)
