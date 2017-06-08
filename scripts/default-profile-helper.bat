@echo off

REM Check Permissions
net session >nul 2>&1
IF NOT %errorLevel% == 0 (
    echo Please run as administrator.
    timeout /t -1
    EXIT
)
set scriptPath="\\MyScriptLocation\"

REM Lets you Drag and drop zip files onto the bat file
IF [%1]==[] (set zipFile=%scriptPath%\DefaultOrgWin10.64.zip) ELSE (set zipFile=%1)

echo(
echo -- Setup Default Profile --
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File "%scriptPath%\default-profile-setup.ps1" %zipFile%

timeout /t -1
