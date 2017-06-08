param(
    [parameter(Mandatory=$true)][string]$DefaultProfileZip,

    [string]$TempFolder = "C:\Windows\Temp",
    [string]$UsersFolder = "$env:SystemDrive\Users",
    [string]$NewDefaultProfileName = "DefaultOrg"
)

Add-Type -AssemblyName System.IO.Compression.FileSystem

$NewDefaultProfileLoc = "$UsersFolder\$NewDefaultProfileName"
    

Write-Host "Extracting" $defaultProfileZip
If (Test-Path "$TempFolder\DefaultProfile\")
{
    Remove-Item -Recurse "$TempFolder\DefaultProfile\"
}
[System.IO.Compression.ZipFile]::ExtractToDirectory("$DefaultProfileZip", "$TempFolder\DefaultProfile\")


# Remove old DefaultDCHP folder
If (Test-Path "$NewDefaultProfileLoc")
{
    Remove-Item -Recurse -Force "$NewDefaultProfileLoc"
}


# Zip holds a single folder called DefaultDCHP
Write-Host ""
Write-Host "Moving Default Profile to $NewDefaultProfileLoc"
Move-Item "$TempFolder\DefaultProfile\$NewDefaultProfileName" "$NewDefaultProfileLoc" -Force

# If Default Apps File exists Apply it
If (Test-Path "$TempFolder\DefaultProfile\default_apps.xml")
{
    Write-Host ""
    Write-Host "Applying Default Applications"
    Dism /online /Import-DefaultAppAssociations:"$TempFolder\DefaultProfile\default_apps.xml"
}

# Remove temporary folder
Remove-Item -Recurse -Force "$TempFolder\DefaultProfile"

# Set owner and permissions on new default profile
Write-Host ""
Write-Host "Set Permissions on new Default Profile"

$Folders = Get-ChildItem -Recurse -Force $NewDefaultProfileLoc
$Folders += Get-Item -Force $NewDefaultProfileLoc

foreach ($Folder in $Folders)
{
    $Path = $Folder.FullName
    $Acl = (Get-Item $Path).GetAccessControl('Access')

    $Group = New-Object System.Security.Principal.NTAccount("BUILTIN", "Administrators")
    $Acl.SetOwner($Group)
    $Acl.SetGroup($Group)

    $Ar = New-Object  System.Security.AccessControl.FileSystemAccessRule("BUILTIN\Users","ReadAndExecute","Allow")
    $Acl.SetAccessRule($Ar)

    Set-Acl -path $Path -AclObject $Acl
}


#Set Permissions back to normal
attrib +h "$NewDefaultProfileLoc"
attrib +a +h "$NewDefaultProfileLoc\NTUSER.dat"
attrib +r +h "$NewDefaultProfileLoc\AppData"
attrib +r    "$NewDefaultProfileLoc\Desktop"


# Unblock all files
Get-ChildItem "$NewDefaultProfileLoc" -Recurse | Unblock-File


# Point Registry to new default profile location

# Remove Drive Letter from path
$RelativePath = Split-Path $NewDefaultProfileLoc -NoQualifier
Write-Host ""
Write-Host "Modify Registry to point to new Default Profile: %SystemDrive%$RelativePath"
sp "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileList" "Default" "%SystemDrive%$RelativePath"
