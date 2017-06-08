# Windows 10 Default Profile set up
These are the instructions on how to setup a customized default profile for Windows 10. The `scripts` folder contains some scripts that will automate the application process of the default profile. You will still need to use these instructions to create a default profile first. 

## Creating the Default Profile through sysprep
On a new install of Windows log in to the administrator and open the command line. 
Run 
```
cd \Windows\System32\Sysprep
sysprep /audit /reboot
```

**Note:** If you log in as another user and windows has a chance to update its apps it won’t let you sysprep. 

**Note:** Don't bother setting the Default apps or Start Menu and Taskbar settings. Those are handled a different way.

Once it reboots set up the administrator account with all the settings you want to be the default.
These are the settings I change.
* `Settings > Privacy` Turn off all options
* `Settings > Network & Internet > Wi-Fi` Disable open hotspots and paid Wi-FI Services
* `Settings > Personalize > Themes > Desktop Icon Settings` Enable Computer
* `Settings > System > Notifications` Disable Get tips, and suggestions
* `Windows Explorer > File > Change Folder and search options > View` Disable Show sync provider notifications
* Add Google Chrome, Gmail, Word, PowerPoint, and Excel Icons to the desktop
* Arrange Icons on the desktop
* `Right click taskbar > Cortana` change to show Cortana icon
* Set default hompage for all browsers
* Change Firefox search to Google and remove unnecessary search providers
* Make sure Firefox and IE don’t ask to be the default all the time
* Make a small registry change to stop Windows from installing suggested apps. run this in PowerShell command
`sp "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SilentInstalledAppsEnabled" 0`

After you are done setting everything up go to the Windows Explorer Right click Quick Access and select Options. Then under click Clear File Explorer history. Clear all browser histories as well.

Create the `unattend.xml` file and paste this in there. You can also just use the one in this repository.
```xml
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="specialize">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <CopyProfile>true</CopyProfile>
        </component>
    </settings>
</unattend>
```

`<CopyProfile>true</CopyProfile>` will tell windows to convert the administrator account to a default profile.
Now run this sysprep command to apply your new default profile <br />
`sysprep /oobe /generalize /reboot /unattend:C:\unattend.xml`

Go through the Windows set up then log into the administrator account.
**Important:** You will need to re-enable the administrator account because sysprep disabled it.

Open the control panel and go to `System > Advanced system settings` Under `User Profiles` click Settings.
Select the Default profile and then copy it to an empty folder.

**Note:** You might want to delete `AppData\Roaming\Microsoft\Windows\Themes` If you set up a default Wallpaper in group policy. If you don't then Windows will still lock the background but the image might be wrong.

## Start Menu and Taskbar
Now we need to set up the start menu and taskbar.
Set up the start menu the way you want it and then open powershell run
`Export-StartLayout -Path layout.xml`

Now edit the xml file and change LayoutModificationTemplate tag to 
```xml
<LayoutModificationTemplate
    xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification"
    xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout"
    xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout"
    xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout"
    Version="1"> 
```

Then at the bottom right after `</DefaultLayoutOverride>` add
```xml
<CustomTaskbarLayoutCollection PinListPlacement="Replace">
    <defaultlayout:TaskbarLayout>
       <taskbar:TaskbarPinList>
        <taskbar:DesktopApp DesktopApplicationLinkPath="%APPDATA%\Microsoft\Windows\Start Menu\Programs\System Tools\File Explorer.lnk" />
        <taskbar:DesktopApp DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Google Chrome.lnk" />
      </taskbar:TaskbarPinList>
    </defaultlayout:TaskbarLayout>
  </CustomTaskbarLayoutCollection>
```
You can modify the `<taskbar:TaskbarPinList>` to include whatever you want. 

Look at `start-layout.xml` for a full example. 

Now we need to check to make sure the file is valid. Open PowerShell and run:<br />
```
cd \
Import-StartLayout -LayoutPath C:\start-layout.xml -MountPath C:
```
If it ran with no errors then you know your xml file is valid.

**Note:** Sometimes it errors out if you don't run it from the root of the system drive

Now in the directory you saved your Default Profile add these folders.
`AppData\Local\Microsoft\Windows\Shell`
in the Shell folder paste your start layout file and name it LayoutModification

**Note:** If the computer doesn't have an application that is in your configuration then it will dissapear from the list and leave a hole. You can build your layout in a way that still looks nice when this happens.

## Applying the new Default Profile
I like to keep the original Default profile for troubleshooting purposes. So I just leave it alone.

Copy your Default Profile to the `C:\Users` directory and rename it to whatever you want. As an example I will be renaming it `DefaultOrg`. Now under its security settings make sure it has the `Users` group has the permissions `Read & Execute, List Folder Contents, and Read`. Make sure to apply it to all subfolders as well.

In the registry under `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList` change the Default Key to point to your new DefaultProfile `$SystemDrive%\Users\DefaultOrg`.

Just change that back whenever you want to go back to the old Default Profile.

Or you could just rename the Old default profile to Default.old and name yours Default. As long as the permissions are correct that will work too.

## Setting the Default Apps
Now set up your default apps in Windows the way you want them. When you are done open a command prompt and run<br />
`Dism /online /Export-DefaultAppAssociations:C:\default-apps.xml`

Take a look at the file make sure it has everything you want. 

**Note:** It's best to leave it as complete as possible because if Windows doesn't have a default app for something it gives a notification that it reset that default for each file type.

To set the default apps run:<br />
`Dism /online /Import-DefaultAppAssociations:C:\default-apps.xml`

## Deleting a Users Profile
When testing your new default profile you'll probably need to reset your account.

To reset a user and make it apply the Default Profile again you need to log in as a different user delete their profile folder under `C:\Users` then delete their registry key under `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList`.

**Note:** If you don't delete the key Windows will log you in under a temporary account.

