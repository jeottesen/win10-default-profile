# Windows 10 Default Profile set up

## Creating the Default Profile through sysprep
On a new install of Windows before log in to the administrator and open the command line. 
Run 
```
cd \Windows\System32\Sysprep
sysprep /audit /reboot
```

Note: If you log in as another user and windows has a chance to update its apps it won’t let you sysprep unless you reset them.


Once it reboots set up the administrator account with all the settings you want to be the default.
These are the settings I change.
•    Settings > Privacy turn off all options
•    Settings > Network & Internet > Wi-Fi: Disable open hotspots and paid Wi-FI Services
•    Settings > Personalize > Themes > Desktop Icon Settings: Enable Computer
•    Settings > System > Notifications: Disable Get tips, and suggestions
•    Windows Explorer > File > Change Folder and search options > View: Disable Show sync provider notifications
•    Add Google Chrome, Gmail, Word, PowerPoint, and Excel Icons to the desktop
•    Arrange Icons on the desktop
•    Right Click Taskbar under Cortana change to show Cortana icon
•    Set https://weber.edu as the default on all browsers
•    Change Firefox search to Google and remove unnecessary search providers
•    Make sure Firefox and IE don’t ask to be the default all the time

After you are done setting everything up go to the Windows Explorer Right click Quick Access and select Options. Then under click Clear File Explorer history. Clear all browser histories as well.

Create the unattend.xml file and past this in there.
```
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="specialize">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <CopyProfile>true</CopyProfile>
        </component>
    </settings>
</unattend>
```

You need a valid unattend.xml file but the Important part is `<CopyProfile>true</CopyProfile>`
This will tell windows to convert the administrator account to a default profile.
Run
`sysprep /oobe /generalize /reboot /unattend:C:\unattend.xml`

Go through the Windows set up then log into the administrator account. 
Open the control panel and go to System > Advanced system settings: Under User Profiles click Settings
Click the Default profile and then copy it to an empty folder.

## Start Menu and taskbar
Now we need to set up the start menu and taskbar.
Set up the start menu the way you want it and then open powershell run
Export-StartLayout -Path layout.xml

Now edit the xml file and change LayoutModificationTemplate tag to 
<LayoutModificationTemplate
    xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification"
    xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout"
    xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout"
    xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout"
    Version="1"> 

Then at the bottom right after </DefaultLayoutOverride> add
<CustomTaskbarLayoutCollection PinListPlacement="Replace">
    <defaultlayout:TaskbarLayout>
       <taskbar:TaskbarPinList>
        <taskbar:DesktopApp DesktopApplicationLinkPath="%APPDATA%\Microsoft\Windows\Start Menu\Programs\System Tools\File Explorer.lnk" />
        <taskbar:DesktopApp DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Google Chrome.lnk" />
      </taskbar:TaskbarPinList>
    </defaultlayout:TaskbarLayout>
  </CustomTaskbarLayoutCollection>

There is a full example here


