# Scripts

I made this script to set up the default profile automatically. I just put it on a file share with a bunch of zip files containing different default profiles I have made.

The zips have to follow a specific structure for the script to work
```
|-- DefaultOrgWin10.64.zip/
|   | DefaultOrg/       # Has to match the variable in the powershell script
|   | default-apps.xml  # Optional
```

The helper script allows you to drag and drop zip files onto the bat to apply different default profiles quickly. 
It also runs the powershell script without changing making you change the execution policy.

**Note:** You will need to modify the scripts to point to the right folders.
