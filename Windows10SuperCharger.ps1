Set-ExecutionPolicy Unrestricted -Scope CurrentUser
$CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
if($CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
{
  Get-Date
}
else
{
  Write-Output "Running PowerShell Elevated."
  $ElevatedProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
  $ElevatedProcess.Arguments = "& '" + $script:MyInvocation.MyCommand.Path + "'"
  $ElevatedProcess.Verb = "runas"
  [System.Diagnostics.Process]::Start($ElevatedProcess)
  Exit
}

Start-Process https://raw.githubusercontent.com/FlarosOverfield/Windows10SuperCharger/trainer/README.md
$pcname = Read-Host -Prompt "THIS IS YOUR LAST CHANCE TO REVIEW ALL REQUIREMENTS. IF EVERYTHING IS READY, ENTER THIS PC'S DESIRED NAME TO BEGIN."
Rename-Computer -NewName $pcname -Force
Write-Output "SUPERCHARGING..."

Write-Output "Preventing Windows Update restarts."
net stop wuauserv

Write-Output "Preventing Sleep and Hibernation."
#powercfg /S 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
#powercfg /setdcvalueindex SCHEME_CURRENT SUB_ENERGYSAVER ESBATTTHRESHOLD 50
powercfg /X monitor-timeout-ac 0
powercfg /X monitor-timeout-dc 0
powercfg /X disk-timeout-ac 0
powercfg /X disk-timeout-dc 0
powercfg /X standby-timeout-ac 0
powercfg /X standby-timeout-dc 0
powercfg /X hibernate-timeout-ac 0
powercfg /X hibernate-timeout-dc 0
#powercfg /H off

Write-Output "Disabling SMBv1 to avoid EternalBlue because sadly we are STILL sharing oxygen with people running Windows XP in 2022."
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force

Write-Output "Setting Ethernet connections to Private and enabling Remote Desktop. This is required to fix SAMBA. If you see a red error here, you're on WiFi, and will need to enable Private manually."
Set-NetConnectionProfile -Name "Network" -NetworkCategory Private
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

Write-Output "Checking if Z drive exists."
$pathExists = Test-Path -Path "Z:\"
If ($pathExists) {
Write-Output "Z drive detected."
If ($pcname = server) {New-SmbShare -Name "Z" -Path "Z:\" -FullAccess "everyone"}
}
else {
Write-Output "Z drive not detected, attempting to map it from a server."
net use Z: \\server\z /persistent:yes
}
$pathExists = Test-Path -Path "Z:\" #Declared twice to clear RAM
If ($pathExists) {
Write-Output "Z drive fully armed, commencing user folder redirect. If Temp REG file already exists, it will be deleted to avoid conflicts with Add-Content."
Set-Location C:\Users
Remove-Item -Path C:\Users\User.reg -Force
New-item -Path . -Name "User.reg"
Write-Output "Printing REG File. This Script will use Add-Content to a REG file in the user folder instead of using New-Item, because it makes it way easier for new users to review what changed, by opening the REG file in the user folder."
Add-Content C:\Users\User.reg "Windows Registry Editor Version 5.00

;Move User folder to Z:\Documents, Regedit pass.
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders]
""NetHood""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,4c,00,69,00,6e,00,6b,00,73,00,00,00
""PrintHood""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,4c,00,69,00,6e,00,6b,00,73,00,00,00
""Templates""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,52,00,65,00,63,00,65,00,6e,00,74,00,73,00,00,00
""Desktop""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,44,00,65,00,73,00,6b,00,74,00,6f,00,70,00,00,00
""Favorites""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,4c,00,69,00,6e,00,6b,00,73,00,00,00
""My Pictures""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,\
  00,74,00,73,00,5c,00,50,00,69,00,63,00,74,00,75,00,72,00,65,00,73,00,00,00
""My Music""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,4d,00,75,00,73,00,69,00,63,00,00,00
""My Video""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,56,00,69,00,64,00,65,00,6f,00,73,00,00,00
""Personal""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,00,\
  00
""Start Menu""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,\
  00,74,00,73,00,5c,00,4c,00,69,00,6e,00,6b,00,73,00,00,00
""Programs""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,4c,00,69,00,6e,00,6b,00,73,00,00,00
""Startup""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,53,00,74,00,61,00,72,00,74,00,75,00,70,00,00,00
""Recent""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,74,\
  00,73,00,5c,00,52,00,65,00,63,00,65,00,6e,00,74,00,73,00,00,00
""SendTo""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,74,\
  00,73,00,5c,00,4c,00,69,00,6e,00,6b,00,73,00,00,00
""Cache""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,74,\
  00,73,00,5c,00,52,00,65,00,63,00,65,00,6e,00,74,00,73,00,00,00
""Cookies""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,52,00,65,00,63,00,65,00,6e,00,74,00,73,00,00,00
""History""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,52,00,65,00,63,00,65,00,6e,00,74,00,73,00,00,00

;Move User folder to Z:\Documents, Properties pass.
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders]
;3D Objects
""{31C0DD25-9439-4F12-BF41-7FF4EDA38722}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,33,00,44,00,20,00,4f,00,62,\
  00,6a,00,65,00,63,00,74,00,73,00,00,00
;Contacts
""{56784854-C6CB-462B-8169-88E350ACB882}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,43,00,6f,00,6e,00,74,00,61,\
  00,63,00,74,00,73,00,00,00
;Desktop
""{754AC886-DF64-4CBA-86B5-F7FBF4FBCEF5}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,44,00,65,00,73,00,6b,00,74,\
  00,6f,00,70,00,00,00
;Documents
""{F42EE2D3-909F-4907-8871-4C22FC0BF756}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,44,00,6f,00,63,00,75,00,6d,\
  00,65,00,6e,00,74,00,73,00,00,00
;Downloads
""{374DE290-123F-4565-9164-39C4925E467B}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,44,00,6f,00,77,00,6e,00,6c,\
  00,6f,00,61,00,64,00,73,00,00,00
;Downloads, uh, again
""{7D83EE9B-2244-4E70-B1F5-5393042AF1E4}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,44,00,6f,00,77,00,6e,00,6c,\
  00,6f,00,61,00,64,00,73,00,00,00
;Links
""{BFB9D5E0-C6A9-404C-B2B2-AE6DB6AF4968}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,4c,00,69,00,6e,00,6b,00,73,\
  00,00,00
;Music
""{A0C69A99-21C8-4671-8703-7934162FCF1D}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,4d,00,75,00,73,00,69,00,63,\
  00,00,00
;Pictures
""{0DDD015D-B06C-45D5-8C4C-F59713854639}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,50,00,69,00,63,00,74,00,75,\
  00,72,00,65,00,73,00,00,00
;Saved Games
""{4C5C32FF-BB9D-43B0-B5B4-2D72E54EAAA4}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,53,00,61,00,76,00,65,00,64,\
  00,20,00,47,00,61,00,6d,00,65,00,73,00,00,00
;Recents
""{7D1D3A04-DEBB-4115-95CF-2F29DA2920DA}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,52,00,65,00,63,00,65,00,6e,\
  00,74,00,73,00,00,00
;Videos
""{35286A68-3C57-41A1-BBB1-0EAE73D76C95}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,56,00,69,00,64,00,65,00,6f,\
  00,73,00,00,00"
Start-Sleep 1
Write-Output "Merging."
Reg import C:\Users\User.reg
}
else {
Write-Output "Z Drive not found, aborting user folder redirect."
}

Write-Output "Disabling SSD-unfriendly Paging."
fsutil behavior set DisableLastAccess 1
fsutil behavior set EncryptPagingFile 0

Write-Output "If Temp REG file already exists, it will be deleted to avoid conflicts with Add-Content."
Set-Location C:\Users
Remove-Item -Path C:\Users\Temp.reg -Force
New-item -Path . -Name "Temp.reg"
Write-Output "Printing REG File. This Script will use Add-Content to a REG file in the user folder instead of using New-Item, because it makes it way easier for new users to review what changed, by opening the REG file in the user folder."
Add-Content C:\Users\Temp.reg "Windows Registry Editor Version 5.00

;MAJOR TWEAKS

;Move User folder to Z:\Documents, Regedit pass.
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders]
""NetHood""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,4c,00,69,00,6e,00,6b,00,73,00,00,00
""PrintHood""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,4c,00,69,00,6e,00,6b,00,73,00,00,00
""Templates""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,52,00,65,00,63,00,65,00,6e,00,74,00,73,00,00,00
""Desktop""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,44,00,65,00,73,00,6b,00,74,00,6f,00,70,00,00,00
""Favorites""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,4c,00,69,00,6e,00,6b,00,73,00,00,00
""My Pictures""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,\
  00,74,00,73,00,5c,00,50,00,69,00,63,00,74,00,75,00,72,00,65,00,73,00,00,00
""My Music""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,4d,00,75,00,73,00,69,00,63,00,00,00
""My Video""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,56,00,69,00,64,00,65,00,6f,00,73,00,00,00
""Personal""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,00,\
  00
""Start Menu""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,\
  00,74,00,73,00,5c,00,4c,00,69,00,6e,00,6b,00,73,00,00,00
""Programs""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,4c,00,69,00,6e,00,6b,00,73,00,00,00
""Startup""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,53,00,74,00,61,00,72,00,74,00,75,00,70,00,00,00
""Recent""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,74,\
  00,73,00,5c,00,52,00,65,00,63,00,65,00,6e,00,74,00,73,00,00,00
""SendTo""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,74,\
  00,73,00,5c,00,4c,00,69,00,6e,00,6b,00,73,00,00,00
""Cache""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,74,\
  00,73,00,5c,00,52,00,65,00,63,00,65,00,6e,00,74,00,73,00,00,00
""Cookies""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,52,00,65,00,63,00,65,00,6e,00,74,00,73,00,00,00
""History""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,52,00,65,00,63,00,65,00,6e,00,74,00,73,00,00,00

;Move User folder to Z:\Documents, Properties pass.
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders]
;3D Objects
""{31C0DD25-9439-4F12-BF41-7FF4EDA38722}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,33,00,44,00,20,00,4f,00,62,\
  00,6a,00,65,00,63,00,74,00,73,00,00,00
;Contacts
""{56784854-C6CB-462B-8169-88E350ACB882}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,43,00,6f,00,6e,00,74,00,61,\
  00,63,00,74,00,73,00,00,00
;Desktop
""{754AC886-DF64-4CBA-86B5-F7FBF4FBCEF5}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,44,00,65,00,73,00,6b,00,74,\
  00,6f,00,70,00,00,00
;Documents
""{F42EE2D3-909F-4907-8871-4C22FC0BF756}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,44,00,6f,00,63,00,75,00,6d,\
  00,65,00,6e,00,74,00,73,00,00,00
;Downloads
""{374DE290-123F-4565-9164-39C4925E467B}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,44,00,6f,00,77,00,6e,00,6c,\
  00,6f,00,61,00,64,00,73,00,00,00
;Downloads, uh, again
""{7D83EE9B-2244-4E70-B1F5-5393042AF1E4}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,44,00,6f,00,77,00,6e,00,6c,\
  00,6f,00,61,00,64,00,73,00,00,00
;Links
""{BFB9D5E0-C6A9-404C-B2B2-AE6DB6AF4968}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,4c,00,69,00,6e,00,6b,00,73,\
  00,00,00
;Music
""{A0C69A99-21C8-4671-8703-7934162FCF1D}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,4d,00,75,00,73,00,69,00,63,\
  00,00,00
;Pictures
""{0DDD015D-B06C-45D5-8C4C-F59713854639}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,50,00,69,00,63,00,74,00,75,\
  00,72,00,65,00,73,00,00,00
;Saved Games
""{4C5C32FF-BB9D-43B0-B5B4-2D72E54EAAA4}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,53,00,61,00,76,00,65,00,64,\
  00,20,00,47,00,61,00,6d,00,65,00,73,00,00,00
;Recents
""{7D1D3A04-DEBB-4115-95CF-2F29DA2920DA}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,52,00,65,00,63,00,65,00,6e,\
  00,74,00,73,00,00,00
;Videos
""{35286A68-3C57-41A1-BBB1-0EAE73D76C95}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,56,00,69,00,64,00,65,00,6f,\
  00,73,00,00,00

;Automatically give important processes higher priority.
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched]
""NonBestEffortLimit""=dword:00000000
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile]
""AlwaysOn""=dword:00000001
""NetworkThrottlingIndex""=dword:ffffffff
""SystemResponsiveness""=dword:00000000
""NoLazyMode""=dword:00000001
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Capture]
""Affinity""=dword:00000007
""Background Only""=""True""
""Clock Rate""=dword:00002710
""GPU Priority""=dword:00000004
""Priority""=dword:00000004
""Scheduling Category""=""Low""
""SFIO Priority""=""Low""
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\DisplayPostProcessing]
""Affinity""=dword:00000000
""Background Only""=""False""
""Clock Rate""=dword:00002710
""GPU Priority""=dword:00000008
""Priority""=dword:00000008
""Scheduling Category""=""High""
""SFIO Priority""=""High""
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Distribution]
""Affinity""=dword:00000007
""Background Only""=""True""
""Clock Rate""=dword:00002710
""GPU Priority""=dword:00000004
""Priority""=dword:00000004
""Scheduling Category""=""Low""
""SFIO Priority""=""Low""
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games]
""Affinity""=dword:00000000
""Background Only""=""False""
""Clock Rate""=dword:00002710
""GPU Priority""=dword:00000008
""Priority""=dword:00000008
""Scheduling Category""=""High""
""SFIO Priority""=""High""
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Playback]
""Affinity""=dword:00000007
""Background Only""=""True""
""Clock Rate""=dword:00002710
""GPU Priority""=dword:00000004
""Priority""=dword:00000004
""Scheduling Category""=""Low""
""SFIO Priority""=""Low""
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio]
""Affinity""=dword:00000000
""Background Only""=""False""
""Clock Rate""=dword:00002710
""GPU Priority""=dword:00000008
""Priority""=dword:00000008
""Scheduling Category""=""High""
""SFIO Priority""=""High""
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Window Manager]
""Affinity""=dword:00000007
""Background Only""=""True""
""Clock Rate""=dword:00002710
""GPU Priority""=dword:00000004
""Priority""=dword:00000004
""Scheduling Category""=""Low""
""SFIO Priority""=""Low""
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio]
""Affinity""=dword:00000000
""Background Only""=""False""
""Clock Rate""=dword:00002710
""GPU Priority""=dword:00000008
""Priority""=dword:00000008
""Scheduling Category""=""High""
""SFIO Priority""=""High""

;Start File Explorer in This PC, show hidden files, enable checkboxes, and other tweaks.
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
""AlwaysShowMenus""=dword:00000001
""AutoCheckSelect""=dword:00000001
""DesktopLivePreviewHoverTime""=dword:00000001
""DisablePreviewDesktop""=dword:00000000
""DisallowShaking""=dword:00000001
""DontPrettyPath""=dword:00000001
""EncryptionContextMenu""=dword:00000001
""EnableTaskGroups""=dword:00000000
""Filter""=dword:00000000
""Hidden""=dword:00000001
""HideDrivesWithNoMedia""=dword:00000000
""HideFileExt""=dword:00000000
""HideIcons""=dword:00000000
""HideMergeConflicts""=dword:00000000
""IconsOnly""=dword:00000000
""LaunchTo""=dword:00000001
""ListviewAlphaSelect""=dword:00000001
""ListviewShadow""=dword:00000001
""MapNetDrvBtn""=dword:00000000
""MultiTaskingAltTabFilter""=dword:00000000
""NavPaneExpandToCurrentFolder""=dword:00000001
""NavPaneShowAllCloudStates""=dword:00000001
""NavPaneShowAllFolders""=dword:00000000
""PersistBrowsers""=dword:00000001
""ReindexedProfile""=dword:00000001
""SeparateProcess""=dword:00000000
""ServerAdminUI""=dword:00000000
""ShellViewReentered""=dword:00000001
""ShowCompColor""=dword:00000001
""ShowCortanaButton""=dword:00000001
""ShowEncryptCompressedColor""=dword:00000001
""ShowInfoTip""=dword:00000001
""ShowSecondsInSystemClock""=dword:00000001
""ShowStatusBar""=dword:00000001
""ShowSuperHidden""=dword:00000001
""ShowTaskViewButton""=dword:00000001
""ShowTypeOverlay""=dword:00000001
""Start_TrackDocs""=dword:00000001
""StartMigratedBrowserPin""=dword:00000001
""StoreAppsOnTaskbar""=dword:00000001
""TaskbarAnimations""=dword:00000001
""TaskbarGlomLevel""=dword:00000001
""TaskbarMigratedBrowserPin""=dword:00000001
""TaskbarSd""=dword:00000000
""TaskbarSizeMove""=dword:00000001
""TaskbarSmallIcons""=dword:00000001
""TypeAhead""=dword:00000000
""WebView""=dword:00000001

;Fix 3D Paint Associations
[HKEY_CLASSES_ROOT\SystemFileAssociations\.3mf\Shell\3D Edit]
@=""@%SystemRoot%\\system32\\mspaint.exe,-59500""
""Extended""=-
[HKEY_CLASSES_ROOT\SystemFileAssociations\.3mf\Shell\3D Edit\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
  00,5c,00,73,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,6d,00,73,00,\
  70,00,61,00,69,00,6e,00,74,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,00,31,\
  00,22,00,20,00,2f,00,46,00,6f,00,72,00,63,00,65,00,42,00,6f,00,6f,00,74,00,\
  73,00,74,00,72,00,61,00,70,00,50,00,61,00,69,00,6e,00,74,00,33,00,44,00,00,\
  00
[HKEY_CLASSES_ROOT\SystemFileAssociations\.bmp\Shell\3D Edit]
@=""@%SystemRoot%\\system32\\mspaint.exe,-59500""
""Extended""=-
[HKEY_CLASSES_ROOT\SystemFileAssociations\.bmp\Shell\3D Edit\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
  00,5c,00,73,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,6d,00,73,00,\
  70,00,61,00,69,00,6e,00,74,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,00,31,\
  00,22,00,20,00,2f,00,46,00,6f,00,72,00,63,00,65,00,42,00,6f,00,6f,00,74,00,\
  73,00,74,00,72,00,61,00,70,00,50,00,61,00,69,00,6e,00,74,00,33,00,44,00,00,\
  00
[HKEY_CLASSES_ROOT\SystemFileAssociations\.fbx\Shell\3D Edit]
@=""@%SystemRoot%\\system32\\mspaint.exe,-59500""
""Extended""=-
[HKEY_CLASSES_ROOT\SystemFileAssociations\.fbx\Shell\3D Edit\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
  00,5c,00,73,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,6d,00,73,00,\
  70,00,61,00,69,00,6e,00,74,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,00,31,\
  00,22,00,20,00,2f,00,46,00,6f,00,72,00,63,00,65,00,42,00,6f,00,6f,00,74,00,\
  73,00,74,00,72,00,61,00,70,00,50,00,61,00,69,00,6e,00,74,00,33,00,44,00,00,\
  00
[HKEY_CLASSES_ROOT\SystemFileAssociations\.gif\Shell\3D Edit]
@=""@%SystemRoot%\\system32\\mspaint.exe,-59500""
""Extended""=-
[HKEY_CLASSES_ROOT\SystemFileAssociations\.gif\Shell\3D Edit\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
  00,5c,00,73,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,6d,00,73,00,\
  70,00,61,00,69,00,6e,00,74,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,00,31,\
  00,22,00,20,00,2f,00,46,00,6f,00,72,00,63,00,65,00,42,00,6f,00,6f,00,74,00,\
  73,00,74,00,72,00,61,00,70,00,50,00,61,00,69,00,6e,00,74,00,33,00,44,00,00,\
  00
[HKEY_CLASSES_ROOT\SystemFileAssociations\.jfif\Shell\3D Edit]
@=""@%SystemRoot%\\system32\\mspaint.exe,-59500""
""Extended""=-
[HKEY_CLASSES_ROOT\SystemFileAssociations\.jfif\Shell\3D Edit\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
  00,5c,00,73,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,6d,00,73,00,\
  70,00,61,00,69,00,6e,00,74,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,00,31,\
  00,22,00,20,00,2f,00,46,00,6f,00,72,00,63,00,65,00,42,00,6f,00,6f,00,74,00,\
  73,00,74,00,72,00,61,00,70,00,50,00,61,00,69,00,6e,00,74,00,33,00,44,00,00,\
  00
[HKEY_CLASSES_ROOT\SystemFileAssociations\.jpe\Shell\3D Edit]
@=""@%SystemRoot%\\system32\\mspaint.exe,-59500""
""Extended""=-
[HKEY_CLASSES_ROOT\SystemFileAssociations\.jpe\Shell\3D Edit\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
  00,5c,00,73,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,6d,00,73,00,\
  70,00,61,00,69,00,6e,00,74,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,00,31,\
  00,22,00,20,00,2f,00,46,00,6f,00,72,00,63,00,65,00,42,00,6f,00,6f,00,74,00,\
  73,00,74,00,72,00,61,00,70,00,50,00,61,00,69,00,6e,00,74,00,33,00,44,00,00,\
  00
[HKEY_CLASSES_ROOT\SystemFileAssociations\.jpeg\Shell\3D Edit]
@=""@%SystemRoot%\\system32\\mspaint.exe,-59500""
""Extended""=-
[HKEY_CLASSES_ROOT\SystemFileAssociations\.jpeg\Shell\3D Edit\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
  00,5c,00,73,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,6d,00,73,00,\
  70,00,61,00,69,00,6e,00,74,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,00,31,\
  00,22,00,20,00,2f,00,46,00,6f,00,72,00,63,00,65,00,42,00,6f,00,6f,00,74,00,\
  73,00,74,00,72,00,61,00,70,00,50,00,61,00,69,00,6e,00,74,00,33,00,44,00,00,\
  00
[HKEY_CLASSES_ROOT\SystemFileAssociations\.jpg\Shell\3D Edit]
@=""@%SystemRoot%\\system32\\mspaint.exe,-59500""
""Extended""=-
[HKEY_CLASSES_ROOT\SystemFileAssociations\.jpg\Shell\3D Edit\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
  00,5c,00,73,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,6d,00,73,00,\
  70,00,61,00,69,00,6e,00,74,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,00,31,\
  00,22,00,20,00,2f,00,46,00,6f,00,72,00,63,00,65,00,42,00,6f,00,6f,00,74,00,\
  73,00,74,00,72,00,61,00,70,00,50,00,61,00,69,00,6e,00,74,00,33,00,44,00,00,\
  00
[HKEY_CLASSES_ROOT\SystemFileAssociations\.png\Shell\3D Edit]
@=""@%SystemRoot%\\system32\\mspaint.exe,-59500""
""Extended""=-
[HKEY_CLASSES_ROOT\SystemFileAssociations\.png\Shell\3D Edit\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
  00,5c,00,73,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,6d,00,73,00,\
  70,00,61,00,69,00,6e,00,74,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,00,31,\
  00,22,00,20,00,2f,00,46,00,6f,00,72,00,63,00,65,00,42,00,6f,00,6f,00,74,00,\
  73,00,74,00,72,00,61,00,70,00,50,00,61,00,69,00,6e,00,74,00,33,00,44,00,00,\
  00
[HKEY_CLASSES_ROOT\SystemFileAssociations\.tif\Shell\3D Edit]
@=""@%SystemRoot%\\system32\\mspaint.exe,-59500""
""Extended""=-
[HKEY_CLASSES_ROOT\SystemFileAssociations\.tif\Shell\3D Edit\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
  00,5c,00,73,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,6d,00,73,00,\
  70,00,61,00,69,00,6e,00,74,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,00,31,\
  00,22,00,20,00,2f,00,46,00,6f,00,72,00,63,00,65,00,42,00,6f,00,6f,00,74,00,\
  73,00,74,00,72,00,61,00,70,00,50,00,61,00,69,00,6e,00,74,00,33,00,44,00,00,\
  00
[HKEY_CLASSES_ROOT\SystemFileAssociations\.tiff\Shell\3D Edit]
@=""@%SystemRoot%\\system32\\mspaint.exe,-59500""
""Extended""=-
[HKEY_CLASSES_ROOT\SystemFileAssociations\.tiff\Shell\3D Edit\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
  00,5c,00,73,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,6d,00,73,00,\
  70,00,61,00,69,00,6e,00,74,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,00,31,\
  00,22,00,20,00,2f,00,46,00,6f,00,72,00,63,00,65,00,42,00,6f,00,6f,00,74,00,\
  73,00,74,00,72,00,61,00,70,00,50,00,61,00,69,00,6e,00,74,00,33,00,44,00,00,\
  00

;Fix Image Preview Associations
[HKEY_CLASSES_ROOT\SystemFileAssociations\.avci\ShellEx\ContextMenuHandlers\ShellImagePreview]
@=""{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}""
[HKEY_CLASSES_ROOT\SystemFileAssociations\.avif\ShellEx\ContextMenuHandlers\ShellImagePreview]
@=""{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}""
[HKEY_CLASSES_ROOT\SystemFileAssociations\.bmp\ShellEx\ContextMenuHandlers\ShellImagePreview]
@=""{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}""
[HKEY_CLASSES_ROOT\SystemFileAssociations\.dds\ShellEx\ContextMenuHandlers\ShellImagePreview]
@=""{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}""
[HKEY_CLASSES_ROOT\SystemFileAssociations\.dib\ShellEx\ContextMenuHandlers\ShellImagePreview]
@=""{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}""
[HKEY_CLASSES_ROOT\SystemFileAssociations\.gif\ShellEx\ContextMenuHandlers\ShellImagePreview]
@=""{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}""
[HKEY_CLASSES_ROOT\SystemFileAssociations\.heic\ShellEx\ContextMenuHandlers\ShellImagePreview]
@=""{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}""
[HKEY_CLASSES_ROOT\SystemFileAssociations\.heif\ShellEx\ContextMenuHandlers\ShellImagePreview]
@=""{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}""
[HKEY_CLASSES_ROOT\SystemFileAssociations\.ico\ShellEx\ContextMenuHandlers\ShellImagePreview]
@=""{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}""
[HKEY_CLASSES_ROOT\SystemFileAssociations\.jfif\ShellEx\ContextMenuHandlers\ShellImagePreview]
@=""{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}""
[HKEY_CLASSES_ROOT\SystemFileAssociations\.jpe\ShellEx\ContextMenuHandlers\ShellImagePreview]
@=""{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}""
[HKEY_CLASSES_ROOT\SystemFileAssociations\.jpeg\ShellEx\ContextMenuHandlers\ShellImagePreview]
@=""{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}""
[HKEY_CLASSES_ROOT\SystemFileAssociations\.jpg\ShellEx\ContextMenuHandlers\ShellImagePreview]
@=""{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}""
[HKEY_CLASSES_ROOT\SystemFileAssociations\.jxr\ShellEx\ContextMenuHandlers\ShellImagePreview]
@=""{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}""
[HKEY_CLASSES_ROOT\SystemFileAssociations\.png\ShellEx\ContextMenuHandlers\ShellImagePreview]
@=""{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}""
[HKEY_CLASSES_ROOT\SystemFileAssociations\.rle\ShellEx\ContextMenuHandlers\ShellImagePreview]
@=""{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}""
[HKEY_CLASSES_ROOT\SystemFileAssociations\.tif\ShellEx\ContextMenuHandlers\ShellImagePreview]
@=""{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}""
[HKEY_CLASSES_ROOT\SystemFileAssociations\.tiff\ShellEx\ContextMenuHandlers\ShellImagePreview]
@=""{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}""
[HKEY_CLASSES_ROOT\SystemFileAssociations\.wdp\ShellEx\ContextMenuHandlers\ShellImagePreview]
@=""{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}""
[HKEY_CLASSES_ROOT\SystemFileAssociations\.webp\ShellEx\ContextMenuHandlers\ShellImagePreview]
@=""{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}""

;Add all user folders to start menu.
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\Start]
""AllowPinnedFolderDocuments""=dword:00000001
""AllowPinnedFolderDocuments_ProviderSet""=dword:00000001
""AllowPinnedFolderDownloads""=dword:00000001
""AllowPinnedFolderDownloads_ProviderSet""=dword:00000001
""AllowPinnedFolderFileExplorer""=dword:00000001
""AllowPinnedFolderFileExplorer_ProviderSet""=dword:00000001
""AllowPinnedFolderMusic""=dword:00000001
""AllowPinnedFolderMusic_ProviderSet""=dword:00000001
""AllowPinnedFolderNetwork""=dword:00000001
""AllowPinnedFolderNetwork_ProviderSet""=dword:00000001
""AllowPinnedFolderPersonalFolder""=dword:00000001
""AllowPinnedFolderPersonalFolder_ProviderSet""=dword:00000001
""AllowPinnedFolderPictures""=dword:00000001
""AllowPinnedFolderPictures_ProviderSet""=dword:00000001
""AllowPinnedFolderSettings""=dword:00000001
""AllowPinnedFolderSettings_ProviderSet""=dword:00000001
""AllowPinnedFolderVideos""=dword:00000001
""AllowPinnedFolderVideos_ProviderSet""=dword:00000001

;Force enable Auto Color, disable wallpaper compression, and other theme settings.
[HKEY_CURRENT_USER\Control Panel\Cursors]
""ContactVisualization""=dword:00000001
""GestureVisualization""=dword:0000001f
[HKEY_CURRENT_USER\Control Panel\Desktop]
""CursorBlinkRate""=""100""
""DragHeight""=""4""
""DragWidth""=""4""
""FocusBorderHeight""=dword:00000001
""FocusBorderWidth""=dword:00000001
""ForegroundFlashCount""=dword:00000004
""LowLevelHooksTimeout""=dword:00001000
""MenuShowDelay""=""100""
""PaintDesktopVersion""=dword:00000000
""WaitToKillAppTimeout""=""1000""
""WaitToKillServiceTimeout""=dword:00001000
""WheelScrollChars""=""1""
""WheelScrollLines""=""1""
""AutoColorization""=dword:00000001
""AutoEndTasks""=""1""
""JPEGImportQuality""=dword:00000064
""LogPixels""=dword:00000096
""Win8DpiScaling""=dword:00000000
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize]
""AppsUseLightTheme""=dword:00000000
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize]
""AppsUseLightTheme""=dword:00000000
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\DefaultColors]
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\DefaultColors\HighContrast]
""HotTrackingColor""=dword:0000ffff
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\DefaultColors\Standard]
""HotTrackingColor""=dword:00cc6600
[HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics]
""AppliedDPI""=dword:00000096
""CaptionFont""=hex:f3,ff,ff,ff,00,00,00,00,00,00,00,00,00,00,00,00,bc,02,00,00,00,\
  00,00,01,00,00,00,00,53,00,65,00,67,00,6f,00,65,00,20,00,55,00,49,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
""CaptionHeight""=""-285""
""CaptionWidth""=""-285""

;Restore Classic Photo Viewer
[HKEY_CLASSES_ROOT\Applications\photoviewer.dll]
[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell]
[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open]
""MuiVerb""=""@photoviewer.dll,-3043""
[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,\
6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,\
00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,\
25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,\
00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,\
6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,\
00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,\
5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,\
00,31,00,00,00
[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open\DropTarget]
""Clsid""=""{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}""
[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\print]
[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\print\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,\
6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,\
00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,\
25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,\
00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,\
6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,\
00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,\
5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,\
00,31,00,00,00
[HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\print\DropTarget]
""Clsid""=""{60fd46de-f830-4894-a628-6fa81bc0190d}""

;Disable Ads.
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager]
""SilentInstalledAppsEnabled""=dword:00000000
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager]
""SystemPaneSuggestionsEnabled""=dword:00000000
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
""ShowSyncProviderNotifications""=dword:00000000
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager]
""SoftLandingEnabled""=dword:00000000
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager]
""RotatingLockScreenEnabled""=dword:00000000
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager]
""RotatingLockScreenOverlayEnabled""=dword:00000000
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager]
""SubscribedContent-310093Enabled""=dword:00000000
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo]
""Enabled""=dword:00000000
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager]
""SilentInstalledAppsEnabled""=dword:00000000
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager]
""SubscribedContent-310093Enabled""=dword:00000000

;Make it much easier to double click and trigger hover functions, and fix mouse acceleration.
[HKEY_CURRENT_USER\Control Panel\Mouse]
""DoubleClickHeight""=""4""
""DoubleClickSpeed""=""500""
""DoubleClickWidth""=""4""
""MouseHoverHeight""=""4""
""MouseHoverTime""=""500""
""MouseHoverWidth""=""4""
""MouseSensitivity""=""10""
""MouseSpeed""=""0""
""MouseThreshold1""=""0""
""MouseThreshold2""=""0""
""SmoothMouseXCurve""=hex:\
	00,00,00,00,00,00,00,00,\
	C0,CC,0C,00,00,00,00,00,\
	80,99,19,00,00,00,00,00,\
	40,66,26,00,00,00,00,00,\
	00,33,33,00,00,00,00,00
""SmoothMouseYCurve""=hex:\
	00,00,00,00,00,00,00,00,\
	00,00,38,00,00,00,00,00,\
	00,00,70,00,00,00,00,00,\
	00,00,A8,00,00,00,00,00,\
	00,00,E0,00,00,00,00,00

;Show all options in the Shutdown menu.
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power]
""HibernateEnabled""=dword:00000001
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings]
""ShowHibernateOption""=dword:00000001
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings]
""ShowLockOption""=dword:00000001
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings]
""ShowSleepOption""=dword:00000001
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System]
""HiberbootEnabled""=dword:00000001

;Enable God Mode.
[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{E91B00A7-97F2-4934-B06A-101C194D2333}]
@=""All Tasks""
""InfoTip""=""All Control Panel items in a single view""
""System.ControlPanel.Category""=""5""
[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{E91B00A7-97F2-4934-B06A-101C194D2333}\DefaultIcon]
@=""%SystemRoot%\\System32\\imageres.dll,-27""
[HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{E91B00A7-97F2-4934-B06A-101C194D2333}\Shell\Open\Command]
@=""explorer.exe shell:::{ED7BA470-8E54-465E-825C-99712043E01C}""
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel\NameSpace\{E91B00A7-97F2-4934-B06A-101C194D2333}]
@=""All Tasks""

;Enable GameDVR and advanced GPU scheduling.
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\GraphicsDrivers]
""HwSchMode""=dword:00000002
[HKEY_CURRENT_USER\Software\Microsoft\GameBar]
""AllowAutoGameMode""=dword:00000001
""AutoGameModeEnabled""=dword:00000001
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR]
""AppCaptureEnabled""=dword:00000001
[HKEY_CURRENT_USER\System\GameConfigStore]
""GameDVR_Enabled""=dword:00000001

;Improve TCPIP Performance
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters]
""EnableICMPRedirect""=dword:00000001
""EnablePMTUDiscovery""=dword:00000001
""Tcp1323Opts""=dword:00000000
""GlobalMaxTcpWindowSize""=dword:000016d0
""TcpWindowSize""=dword:000016d0
""MaxConnectionsPerServer""=dword:00000000
""MaxUserPort""=dword:0000fffe
""TcpTimedWaitDelay""=dword:00000020
""EnablePMTUBHDetect""=dword:00000000
""DisableTaskOffload""=dword:00000000
""DefaultTTL""=dword:00000040
""SackOpts""=dword:00000000
""TcpMaxDupAcks""=dword:00000002
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Winsock]
""UseDelayedAcceptance""=dword:00000000
""MaxSockAddrLength""=dword:00000010
""MinSockAddrLength""=dword:00000010

;Disable the fucking Sticky Keys from triggering by pressing shift five times.
[HKEY_CURRENT_USER\Control Panel\Accessibility]
""DynamicScrollbars""=dword:00000000
[HKEY_CURRENT_USER\Control Panel\Accessibility\StickyKeys]
""Flags""=""506""
[HKEY_CURRENT_USER\Control Panel\Accessibility\ToggleKeys]
""Flags""=""58""
[HKEY_CURRENT_USER\Control Panel\Accessibility\Keyboard Response]
""Flags""=""122""

;Disable Hibernation and Fastboot.
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Power]
""HiberbootEnabled""=dword:00000000
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power]
""HibernateEnabledDefault""=dword:00000000
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling]
""PowerThrottlingOff""=dword:00000001

;Show all background apps in Taskbar all the time and show drive letters in front.
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer]
""EnableAutoTray""=dword:00000000
""UserSignedIn""=dword:00000001
""PostAppInstallTasksCompleted""=dword:00000001
""ShowDriveLettersFirst""=dword:00000004

;Disable Forced Windows Updates since tech illiterate users won't stop complaining about something that literally saved them from WannaCry.
[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\WindowsUpdate\AU]
""NoAutoUpdate""=dword:00000001
""AUOptions""=dword:00000002
""ScheduledInstallTime""=dword:00000003
""ScheduledInstallDay""=dword:00000000

;Force enable pinned user folder.
[HKEY_CURRENT_USER\Software\Classes\CLSID\{59031a47-3f72-44a7-89c5-5595fe6b30ee}]
""System.IsPinnedToNameSpaceTree""=dword:00000001
[HKEY_CURRENT_USER\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}]
""System.IsPinnedToNameSpaceTree""=dword:00000001

;Fix Network Drive not showing on Elevated Programs, enable Virtualization, display verbose Logon, and disable UAC.
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System]
""EnableLinkedConnections""=dword:00000001
""EnableVirtualization""=dword:00000001
""VerboseStatus""=dword:00000001
""EnableLUA""=dword:00000000

;Stop automatically deleting thumbnail cache. This fixes folders being locked by Thumbs.db.
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache]
""Autorun""=dword:00000000
[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache]
""Autorun""=dword:00000000

;Enable WINDOWS+V History menu.
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Clipboard]
""EnableClipboardHistory""=dword:00000001
""EnableCloudClipboard""=dword:00000001
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System]
""AllowClipboardHistory""=-
""AllowCrossDeviceClipboard""=-

;Force enable battery time estimation.
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power]
""EnergyEstimationEnabled""=dword:00000001
[HKEY_CURRENT_USER\Software\Microsoft\Shell\USB]
""NotifyOnWeakCharger""=dword:00000001

;Clear page file at shutdown. This WILL increase shutdown time in exchange for security and disk space.
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management]
""ClearPageFileAtShutdown""=dword:00000001
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet]
""EnableActiveProbing""=dword:00000001

;Quickly invert screen with CTRL+Windows+C when legacy x86 programs don't have dark theme.
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\ColorFiltering]
""HotkeyEnabled""=dword:00000001
""Active""=dword:00000000
""FilterType""=dword:00000001

;Prevent SVCHosts from multiplying like Eevee.
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control]
""SvcHostSplitThresholdInKB""=dword:04000000
""WaitToKillServiceTimeout""=""1000""
""HungAppTimeout""=""1000""
""AutoEndTasks""=""1""

;MINOR TWEAKS

;Show Seconds and AM/PM in Taskbar.
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
""ShowSecondsInSystemClock""=dword:00000001

;Show more details during file operations
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager]
""EnthusiastMode""=dword:00000001

;Don't minimize all open windows when shaking a window around. Nnnyyyooooommm
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
""DisallowShaking""=dword:00000001

;Restore the Security Tab in Explorer.
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer]
""NoSecurityTab""=dword:00000000

;Start Snip & Sketch with PRNTSCRN.
[HKEY_CURRENT_USER\Control Panel\Keyboard]
""PrintScreenKeyForSnippingEnabled""=dword:00000001

;Disable the ugly AF Navigation Pane.
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Modules\GlobalSettings\Sizer]
""PageSpaceControlSizer""=hex:a0,00,00,00,00,00,00,00,00,00,00,00,ec,03,00,00

;Force enable camera usage notifications.
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\OEM\Device\Capture]
""NoPhysicalCameraLED""=dword:00000001

;Disable Auto BSOD Restart.
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CrashControl]
""AutoReboot""=dword:00000000

;Disable Startup delay.
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Serialize]
""StartupDelayInMSec""=dword:00000000

;Show Insider Page
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility]
""HideInsiderPage""=dword:00000000

;10X Boot Animation
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\BootControl]
""BootProgressAnimation""=dword:00000001

;Enable Timeline
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System]
""EnableActivityFeed""=dword:00000001

;Force Enable Action Center
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\ImmersiveShell\Launcher]
""DisableLightDismiss""=dword:00000001

;Disable Background Apps
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications]
""GlobalUserDisabled""=dword:00000001

;Disable storing thumbnails in a Thumbs.db file on Network Shared Drives
[HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Windows\Explorer]
""DisableThumbsDBOnNetworkFolders""=dword:00000001

;Restore Toolbars in Taskbar
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer]
""NoToolbarsOnTaskbar""=dword:00000000

;Restore Folder Options
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer]
""NoFolderOptions""=dword:00000000

;Improve TCP Performance
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSMQ\Parameters]
""TCPNoDelay""=dword:00000001

;Small NonElectron Taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
""TaskbarSi""=dword:00000000

;Force Enable Mixed Reality menu.
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Holographic]
""FirstRunSucceeded""=dword:00000001

;Enable Developer Mode
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock]
""AllowAllTrustedApps""=dword:00000001

;Enable automatic registry backup.
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Configuration Manager]
""EnablePeriodicBackup""=dword:00000001

;Force enable show all in context menu
[-HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}]

;MENU TWEAKS

;Boot To UEFI
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Firmware]
""Icon""=""bootux.dll,-1016""
""MUIVerb""=""Boot to UEFI Firmware Settings""
""Position""=""Bottom""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Firmware\command]
@=""powershell -windowstyle hidden -command \""Start-Process cmd -ArgumentList '/s,/c,shutdown /r /fw' -Verb runAs\""""

;Default Apps
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\DefaultApps]
""MUIVerb""=""Default apps""
""Position""=""Bottom""
""Icon""=""imageres.dll,-24""
""SettingsURI""=""ms-settings:defaultapps""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\DefaultApps\command]
""DelegateExecute""=""{556FF0D6-A1EE-49E5-9FA4-90AE116AD744}""

;Send to Compressed Folder
[HKEY_CLASSES_ROOT\CompressedFolder\ShellEx\ContextMenuHandlers\{b8cdcb65-b1bf-4b42-9428-1dfdb7ee92af}]
@=""Compressed (zipped) Folder Menu""

;Install Cab File
[-HKEY_CLASSES_ROOT\CABFolder\Shell\RunAs]
[HKEY_CLASSES_ROOT\CABFolder\Shell\RunAs]
@=""Install Cab File""
""HasLUAShield""=""""
[HKEY_CLASSES_ROOT\CABFolder\Shell\RunAs\Command]
@=""cmd /k dism /online /add-package /packagepath:\""%1\""""

;Kill Not Responding Tasks
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\KillNRTasks]
""icon""=""taskmgr.exe,-30651""
""MUIverb""=""Kill all not responding tasks""
""Position""=""Bottom""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\KillNRTasks\command]
@=""CMD.exe /C taskkill.exe /f /fi \""status eq Not Responding\"" & Pause""

;New .bat File
[HKEY_CLASSES_ROOT\.bat\ShellNew]
""NullFile""=""""

;Open With Notepad
[HKEY_CLASSES_ROOT\*\shell\Open With Notepad]
[HKEY_CLASSES_ROOT\*\shell\Open With Notepad\command]
@=""notepad.exe %1""

;DISM
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\DismContextMenu]
""Icon""=""WmiPrvSE.exe""
""MUIVerb""=""Repair Windows Image""
""Position""=""Bottom""
""SubCommands""=""""
[HKEY_CLASSES_ROOT\DesktopBackground\shell\DismContextMenu\shell\CheckHealth]
""HasLUAShield""=""""
""MUIVerb""=""Check Health of Windows Image""
[HKEY_CLASSES_ROOT\DesktopBackground\shell\DismContextMenu\shell\CheckHealth\command]
@=""PowerShell -windowstyle hidden -command \""Start-Process cmd -ArgumentList '/s,/k, Dism /Online /Cleanup-Image /CheckHealth' -Verb runAs\""""
[HKEY_CLASSES_ROOT\DesktopBackground\shell\DismContextMenu\shell\RestoreHealth]
""HasLUAShield""=""""
""MUIVerb""=""Repair Windows Image""
[HKEY_CLASSES_ROOT\DesktopBackground\shell\DismContextMenu\shell\RestoreHealth\command]
@=""PowerShell -windowstyle hidden -command \""Start-Process cmd -ArgumentList '/s,/k, Dism /Online /Cleanup-Image /RestoreHealth' -Verb runAs\""""

;Restart Explorer
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Restart Explorer]
""icon""=""explorer.exe""
""Position""=""Bottom""
""SubCommands""=""""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Restart Explorer\shell\01menu]
""MUIVerb""=""Restart Explorer Now""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Restart Explorer\shell\01menu\command]
@=hex(2):63,00,6d,00,64,00,2e,00,65,00,78,00,65,00,20,00,2f,00,63,00,20,00,74,\
  00,61,00,73,00,6b,00,6b,00,69,00,6c,00,6c,00,20,00,2f,00,66,00,20,00,2f,00,\
  69,00,6d,00,20,00,65,00,78,00,70,00,6c,00,6f,00,72,00,65,00,72,00,2e,00,65,\
  00,78,00,65,00,20,00,20,00,26,00,20,00,73,00,74,00,61,00,72,00,74,00,20,00,\
  65,00,78,00,70,00,6c,00,6f,00,72,00,65,00,72,00,2e,00,65,00,78,00,65,00,00,\
  00
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Restart Explorer\shell\02menu]
""MUIVerb""=""Restart Explorer with Pause""
""CommandFlags""=dword:00000020
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Restart Explorer\shell\02menu\command]
@=hex(2):63,00,6d,00,64,00,2e,00,65,00,78,00,65,00,20,00,2f,00,63,00,20,00,40,\
  00,65,00,63,00,68,00,6f,00,20,00,6f,00,66,00,66,00,20,00,26,00,20,00,65,00,\
  63,00,68,00,6f,00,2e,00,20,00,26,00,20,00,65,00,63,00,68,00,6f,00,20,00,53,\
  00,74,00,6f,00,70,00,70,00,69,00,6e,00,67,00,20,00,65,00,78,00,70,00,6c,00,\
  6f,00,72,00,65,00,72,00,2e,00,65,00,78,00,65,00,20,00,70,00,72,00,6f,00,63,\
  00,65,00,73,00,73,00,20,00,2e,00,20,00,2e,00,20,00,2e,00,20,00,26,00,20,00,\
  65,00,63,00,68,00,6f,00,2e,00,20,00,26,00,20,00,74,00,61,00,73,00,6b,00,6b,\
  00,69,00,6c,00,6c,00,20,00,2f,00,66,00,20,00,2f,00,69,00,6d,00,20,00,65,00,\
  78,00,70,00,6c,00,6f,00,72,00,65,00,72,00,2e,00,65,00,78,00,65,00,20,00,26,\
  00,20,00,65,00,63,00,68,00,6f,00,2e,00,20,00,26,00,20,00,65,00,63,00,68,00,\
  6f,00,2e,00,20,00,26,00,20,00,65,00,63,00,68,00,6f,00,20,00,57,00,61,00,69,\
  00,74,00,69,00,6e,00,67,00,20,00,74,00,6f,00,20,00,73,00,74,00,61,00,72,00,\
  74,00,20,00,65,00,78,00,70,00,6c,00,6f,00,72,00,65,00,72,00,2e,00,65,00,78,\
  00,65,00,20,00,70,00,72,00,6f,00,63,00,65,00,73,00,73,00,20,00,77,00,68,00,\
  65,00,6e,00,20,00,79,00,6f,00,75,00,20,00,61,00,72,00,65,00,20,00,72,00,65,\
  00,61,00,64,00,79,00,20,00,2e,00,20,00,2e,00,20,00,2e,00,20,00,26,00,20,00,\
  70,00,61,00,75,00,73,00,65,00,20,00,26,00,26,00,20,00,73,00,74,00,61,00,72,\
  00,74,00,20,00,65,00,78,00,70,00,6c,00,6f,00,72,00,65,00,72,00,2e,00,65,00,\
  78,00,65,00,20,00,26,00,26,00,20,00,65,00,78,00,69,00,74,00,00,00

;.bat RunAs
[-HKEY_CLASSES_ROOT\batfile\shell\runas]
[HKEY_CLASSES_ROOT\batfile\shell\runas]
""HasLUAShield""=""""
[HKEY_CLASSES_ROOT\batfile\shell\runas\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
  00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,63,00,6d,00,\
  64,00,2e,00,65,00,78,00,65,00,20,00,2f,00,43,00,20,00,22,00,25,00,31,00,22,\
  00,20,00,25,00,2a,00,00,00
[-HKEY_CLASSES_ROOT\cmdfile\shell\runas]
[HKEY_CLASSES_ROOT\cmdfile\shell\runas]
""HasLUAShield""=""""
[HKEY_CLASSES_ROOT\cmdfile\shell\runas\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
  00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,63,00,6d,00,\
  64,00,2e,00,65,00,78,00,65,00,20,00,2f,00,43,00,20,00,22,00,25,00,31,00,22,\
  00,20,00,25,00,2a,00,00,00
[-HKEY_CLASSES_ROOT\cplfile\shell\runas]
[HKEY_CLASSES_ROOT\cplfile\shell\runas]
""HasLUAShield""=""""
[HKEY_CLASSES_ROOT\cplfile\shell\runas\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
  00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,\
  6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,73,00,68,\
  00,65,00,6c,00,6c,00,33,00,32,00,2e,00,64,00,6c,00,6c,00,2c,00,43,00,6f,00,\
  6e,00,74,00,72,00,6f,00,6c,00,5f,00,52,00,75,00,6e,00,44,00,4c,00,4c,00,41,\
  00,73,00,55,00,73,00,65,00,72,00,20,00,22,00,25,00,31,00,22,00,2c,00,25,00,\
  2a,00,00,00
[-HKEY_CLASSES_ROOT\exefile\shell\runas]
[HKEY_CLASSES_ROOT\exefile\shell\runas]
""HasLUAShield""=""""
[HKEY_CLASSES_ROOT\exefile\shell\runas\command]
@=""\""%1\"" %*""
""IsolatedCommand""=""\""%1\"" %*""
[-HKEY_CLASSES_ROOT\mscfile\shell\RunAs]
[HKEY_CLASSES_ROOT\mscfile\shell\RunAs]
""HasLUAShield""=""""
[HKEY_CLASSES_ROOT\mscfile\shell\RunAs\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
  00,5c,00,73,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,6d,00,6d,00,\
  63,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,00,31,00,22,00,20,00,25,00,2a,\
  00,00,00

;Safe Mode
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\SafeMode]
""icon""=""bootux.dll,-1032""
""MUIVerb""=""Safe Mode""
""Position""=-
""SubCommands""=""""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\SafeMode\shell\001-NormalMode]
@=""Restart in Normal Mode""
""HasLUAShield""=""""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\SafeMode\shell\001-NormalMode\command]
@=""powershell -windowstyle hidden -command \""Start-Process cmd -ArgumentList '/s,/c,bcdedit /deletevalue {current} safeboot & bcdedit /deletevalue {current} safebootalternateshell & shutdown -r -t 00 -f' -Verb runAs\""""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\SafeMode\shell\002-SafeMode]
@=""Restart in Safe Mode""
""HasLUAShield""=""""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\SafeMode\shell\002-SafeMode\command]
@=""powershell -windowstyle hidden -command \""Start-Process cmd -ArgumentList '/s,/c,bcdedit /set {current} safeboot minimal & bcdedit /deletevalue {current} safebootalternateshell & shutdown -r -t 00 -f' -Verb runAs\""""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\SafeMode\shell\003-SafeModeNetworking]
@=""Restart in Safe Mode with Networking""
""HasLUAShield""=""""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\SafeMode\shell\003-SafeModeNetworking\command]
@=""powershell -windowstyle hidden -command \""Start-Process cmd -ArgumentList '/s,/c,bcdedit /set {current} safeboot network & bcdedit /deletevalue {current} safebootalternateshell & shutdown -r -t 00 -f' -Verb runAs\""""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\SafeMode\shell\004-SafeModeCommandPrompt]
@=""Restart in Safe Mode with Command Prompt""
""HasLUAShield""=""""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\SafeMode\shell\004-SafeModeCommandPrompt\command]
@=""powershell -windowstyle hidden -command \""Start-Process cmd -ArgumentList '/s,/c,bcdedit /set {current} safeboot minimal & bcdedit /set {current} safebootalternateshell yes & shutdown -r -t 00 -f' -Verb runAs\""""

;Create Restore Point
[HKEY_CLASSES_ROOT\Directory\Background\shell\Create Restore Point]
""HasLUAShield""=""""
""Icon""=""SystemPropertiesProtection.exe""
[HKEY_CLASSES_ROOT\Directory\Background\shell\Create Restore Point\command]
@=""PowerShell -windowstyle hidden -command \""Start-Process cmd -ArgumentList '/s,/c, PowerShell Checkpoint-Computer -Description \""Manual\"" -RestorePointType \""MODIFY_SETTINGS\""' -Verb runAs\""""
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore]
""SystemRestorePointCreationFrequency""=dword:00000000
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\SystemProtection]
""MUIVerb""=""System Protection""
""HasLUAShield""=""""
""Icon""=""rstrui.exe""
""Position""=""Bottom""
""SubCommands""=""""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\SystemProtection\shell\001flyout]
""MUIVerb""=""System Protection""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\SystemProtection\shell\001flyout\command]
@=""SystemPropertiesProtection.exe""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\SystemProtection\shell\002flyout]
""MUIVerb""=""System Restore""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\SystemProtection\shell\002flyout\command]
@=""rstrui.exe""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\SystemProtection\shell\003flyout]
""MUIVerb""=""Create restore point""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\SystemProtection\shell\003flyout\command]
@=""PowerShell -windowstyle hidden -command \""Start-Process cmd -ArgumentList '/s,/c, PowerShell Checkpoint-Computer -Description \""Manual\"" -RestorePointType \""MODIFY_SETTINGS\""' -Verb runAs\""""

;Timeline
[HKEY_CLASSES_ROOT\Directory\Background\shell\TimeLine]
[HKEY_CLASSES_ROOT\Directory\Background\shell\TimeLine\Command]
@=""explorer shell:::{3080F90E-D7AD-11D9-BD98-0000947B0257}""

;Troubleshooting
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Troubleshooters]
""Icon""=""DiagCpl.dll,-1""
""MUIVerb""=""Troubleshooters""
""Position""=""Bottom""
""SubCommands""=""""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Troubleshooters\shell\01entry]
""MUIVerb""=""Troubleshoot Settings page"" 
""Icon""=""DiagCpl.dll,-1"" 
""SettingsURI""=""ms-settings:troubleshoot""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Troubleshooters\shell\01entry\command]
""DelegateExecute""=""{556FF0D6-A1EE-49E5-9FA4-90AE116AD744}""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Troubleshooters\shell\02entry]
""MUIVerb""=""Classic Troubleshooting applet"" 
""Icon""=""DiagCpl.dll,-1"" 
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Troubleshooters\shell\02entry\command]
@=""explorer shell:::{C58C4893-3BE0-4B45-ABB5-A63E4B8C8651}""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Troubleshooters\shell\03entry]
""Icon""=""DiagCpl.dll,-500""
""MUIVerb""=""Programs""
""CommandFlags""=dword:00000020
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Troubleshooters\shell\03entry\command]
@=""explorer shell:::{C58C4893-3BE0-4B45-ABB5-A63E4B8C8651}\\applications""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Troubleshooters\shell\04entry]
""Icon""=""DiagCpl.dll,-501""
""MUIVerb""=""Hardware and Sound""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Troubleshooters\shell\04entry\command]
@=""explorer shell:::{C58C4893-3BE0-4B45-ABB5-A63E4B8C8651}\\devices""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Troubleshooters\shell\05entry]
""Icon""=""DiagCpl.dll,-503""
""MUIVerb""=""Network and Internet""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Troubleshooters\shell\05entry\command]
@=""explorer shell:::{C58C4893-3BE0-4B45-ABB5-A63E4B8C8651}\\network""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Troubleshooters\shell\06entry]
""Icon""=""DiagCpl.dll,-509""
""MUIVerb""=""System and Security""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Troubleshooters\shell\06entry\command]
@=""explorer shell:::{C58C4893-3BE0-4B45-ABB5-A63E4B8C8651}\\system""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Troubleshooters\shell\07entry]
""MUIVerb""=""All Categories""
""CommandFlags""=dword:00000020
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Troubleshooters\shell\07entry\command]
@=""explorer shell:::{C58C4893-3BE0-4B45-ABB5-A63E4B8C8651}\\listAllPage""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Troubleshooters\shell\08entry]
""MUIVerb""=""History""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Troubleshooters\shell\08entry\command]
@=""explorer shell:::{C58C4893-3BE0-4B45-ABB5-A63E4B8C8651}\\historyPage""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Troubleshooters\shell\09entry]
""MUIVerb""=""Change settings""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Troubleshooters\shell\09entry\command]
@=""explorer shell:::{C58C4893-3BE0-4B45-ABB5-A63E4B8C8651}\\settingPage""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Troubleshooters\shell\10entry]
""MUIVerb""=""Additional Information""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Troubleshooters\shell\10entry\command]
@=""explorer shell:::{C58C4893-3BE0-4B45-ABB5-A63E4B8C8651}\\resultPage""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Troubleshooters\shell\11entry]
""MUIVerb""=""Search Results""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Troubleshooters\shell\11entry\command]
@=""explorer shell:::{C58C4893-3BE0-4B45-ABB5-A63E4B8C8651}\\searchPage""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Troubleshooters\shell\12entry]
""MUIVerb""=""Remote Assistance""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Troubleshooters\shell\12entry\command]
@=""explorer shell:::{C58C4893-3BE0-4B45-ABB5-A63E4B8C8651}\\raPage""

;New .vbs File
[HKEY_CLASSES_ROOT\.vbs\ShellNew]
""NullFile""=""""
""ItemName""=hex(2):40,00,25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,\
  6f,00,74,00,25,00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,\
  00,77,00,73,00,68,00,65,00,78,00,74,00,2e,00,64,00,6c,00,6c,00,2c,00,2d,00,\
  34,00,38,00,30,00,32,00,00,00

;Windows Tools
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsTools]
""Position""=""Bottom""
""Icon""=hex(2):25,00,73,00,79,00,73,00,74,00,65,00,6d,00,72,00,6f,00,6f,00,74,\
  00,25,00,5c,00,73,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,69,00,\
  6d,00,61,00,67,00,65,00,72,00,65,00,73,00,2e,00,64,00,6c,00,6c,00,2c,00,2d,\
  00,31,00,31,00,34,00,00,00
""MUIVerb""=""Windows Tools""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsTools\command]
@=""explorer.exe shell:::{D20EA4E1-3957-11d2-A40B-0C5020524153}""

;Delete Folder Contents
[HKEY_CLASSES_ROOT\Directory\shell\Empty]
""Icon""=""shell32.dll,-16715""
""MUIVerb""=""Delete Folder Contents""
""Position""=""bottom""
""Extended""=-
""SubCommands""=""""
[HKEY_CLASSES_ROOT\Directory\shell\Empty\shell\001flyout]
""Icon""=""shell32.dll,-16715""
""MUIVerb""=""Delete Folder Contents and Subfolders""
[HKEY_CLASSES_ROOT\Directory\shell\Empty\shell\001flyout\command]
@=""cmd /c title Empty \""%1\"" & (cmd /c echo. & echo This will permanently delete everything in this folder. & echo. & choice /c:yn /m \""Are you sure?\"") & (if errorlevel 2 exit) & (cmd /c rd /s /q \""%1\"" & md \""%1\"")""
[HKEY_CLASSES_ROOT\Directory\shell\Empty\shell\002flyout]
""Icon""=""shell32.dll,-16715""
""MUIVerb""=""Delete Folder Contents but Not Subfolders""
[HKEY_CLASSES_ROOT\Directory\shell\Empty\shell\002flyout\command]
@=""cmd /c title Empty \""%1\"" & (cmd /c echo. & echo This will permanently delete everything in this folder, but not subfolders. & echo. & choice /c:yn /m \""Are you sure?\"") & (if errorlevel 2 exit) & (cmd /c \""cd /d %1 && del /f /q *.*\"")""

;Clean Up Drives
[HKEY_CLASSES_ROOT\Drive\shell\Windows.CleanUp]
""CommandStateSync""=""""
""ExplorerCommandHandler""=""{9cca66bb-9c78-4e59-a76f-a5e9990b8aa0}""
""Icon""=""%SystemRoot%\\System32\\cleanmgr.exe,-104""
""ImpliedSelectionModel""=dword:00000001

;Burn ISO File
[HKEY_CLASSES_ROOT\Windows.IsoFile\shell\burn]
""MUIVerb""=hex(2):40,00,25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,\
  6f,00,74,00,25,00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,\
  00,69,00,73,00,6f,00,62,00,75,00,72,00,6e,00,2e,00,65,00,78,00,65,00,2c,00,\
  2d,00,33,00,35,00,31,00,00,00
[HKEY_CLASSES_ROOT\Windows.IsoFile\shell\burn\command]
@=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
  00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,69,00,73,00,\
  6f,00,62,00,75,00,72,00,6e,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,00,31,\
  00,22,00,00,00

;Optimize Drives
  [HKEY_CLASSES_ROOT\Drive\shell\dfrgui]
""MUIVerb""=""Optimize drives""
""Icon""=""dfrgui.exe""
[HKEY_CLASSES_ROOT\Drive\shell\dfrgui\command]
@=""dfrgui.exe""

;Inheritance
[HKEY_CLASSES_ROOT\*\shell\InheritedPermissions]
""MUIVerb""=""Inherited Permissions""
""HasLUAShield""=""""
""NoWorkingDirectory""=""""
""Position""=""Bottom""
""SubCommands""=""""
[HKEY_CLASSES_ROOT\*\shell\InheritedPermissions\shell\001flyout]
""MUIVerb""=""Enable inheritance""
""HasLUAShield""=""""
[HKEY_CLASSES_ROOT\*\shell\InheritedPermissions\shell\001flyout\command]
@=""powershell -windowstyle hidden -command \""Start-Process cmd -ArgumentList '/c icacls \\\""%1\\\"" /inheritance:e & pause' -Verb runAs\""""
[HKEY_CLASSES_ROOT\*\shell\InheritedPermissions\shell\002flyout]
""MUIVerb""=""Disable inheritance and convert into explicit permissions""
""HasLUAShield""=""""
[HKEY_CLASSES_ROOT\*\shell\InheritedPermissions\shell\002flyout\command]
@=""powershell -windowstyle hidden -command \""Start-Process cmd -ArgumentList '/c icacls \\\""%1\\\"" /inheritance:d & pause' -Verb runAs\""""
[HKEY_CLASSES_ROOT\*\shell\InheritedPermissions\shell\003flyout]
""MUIVerb""=""Disable inheritance and remove""
""HasLUAShield""=""""
[HKEY_CLASSES_ROOT\*\shell\InheritedPermissions\shell\003flyout\command]
@=""powershell -windowstyle hidden -command \""Start-Process cmd -ArgumentList '/c icacls \\\""%1\\\"" /inheritance:r & pause' -Verb runAs\""""
[HKEY_CLASSES_ROOT\Directory\shell\InheritedPermissions]
""MUIVerb""=""Inherited Permissions""
""HasLUAShield""=""""
""NoWorkingDirectory""=""""
""Position""=""Bottom""
""SubCommands""=""""
[HKEY_CLASSES_ROOT\Directory\shell\InheritedPermissions\shell\001flyout]
""MUIVerb""=""Enable inheritance""
""HasLUAShield""=""""
[HKEY_CLASSES_ROOT\Directory\shell\InheritedPermissions\shell\001flyout\command]
@=""powershell -windowstyle hidden -command \""Start-Process cmd -ArgumentList '/c icacls \\\""%1\\\"" /inheritance:e & pause' -Verb runAs\""""
[HKEY_CLASSES_ROOT\Directory\shell\InheritedPermissions\shell\002flyout]
""MUIVerb""=""Disable inheritance and convert into explicit permissions""
""HasLUAShield""=""""
[HKEY_CLASSES_ROOT\Directory\shell\InheritedPermissions\shell\002flyout\command]
@=""powershell -windowstyle hidden -command \""Start-Process cmd -ArgumentList '/c icacls \\\""%1\\\"" /inheritance:d & pause' -Verb runAs\""""
[HKEY_CLASSES_ROOT\Directory\shell\InheritedPermissions\shell\003flyout]
""MUIVerb""=""Disable inheritance and remove""
""HasLUAShield""=""""
[HKEY_CLASSES_ROOT\Directory\shell\InheritedPermissions\shell\003flyout\command]
@=""powershell -windowstyle hidden -command \""Start-Process cmd -ArgumentList '/c icacls \\\""%1\\\"" /inheritance:r & pause' -Verb runAs\""""

;System Checking
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\SFC]
""Icon""=""WmiPrvSE.exe""
""MUIVerb""=""System File Checker""
""Position""=""Bottom""
""Extended""=-
""SubCommands""=""""
[HKEY_CLASSES_ROOT\DesktopBackground\shell\SFC\shell\001menu]
""HasLUAShield""=""""
""MUIVerb""=""Run System File Checker""
[HKEY_CLASSES_ROOT\DesktopBackground\shell\SFC\shell\001menu\command]
@=""PowerShell -windowstyle hidden -command \""Start-Process cmd -ArgumentList '/s,/k, sfc /scannow' -Verb runAs\""""
[HKEY_CLASSES_ROOT\DesktopBackground\shell\SFC\shell\002menu]
""MUIVerb""=""System File Checker log""
[HKEY_CLASSES_ROOT\DesktopBackground\shell\SFC\shell\002menu\command]
@=""PowerShell (sls [SR] $env:windir\\Logs\\CBS\\CBS.log -s).Line >\""$env:userprofile\\Desktop\\sfcdetails.txt\""""

;Copy As Path
[HKEY_CLASSES_ROOT\Allfilesystemobjects\shell\windows.copyaspath]
@=""Copy &as path""
""Icon""=""imageres.dll,-5302""
""InvokeCommandOnSelection""=dword:00000001
""VerbHandler""=""{f3d06e7c-1e45-4a26-847e-f9fcdee59be0}""
""VerbName""=""copyaspath""

;Preview Pane
[HKEY_CLASSES_ROOT\AllFilesystemObjects\shell\Windows.previewpane]
""CanonicalName""=""{1380d028-a77f-4c12-96c7-ea276333f982}""
""Description""=""@shell32.dll,-31416""
""Icon""=""shell32.dll,-16814""
""MUIVerb""=""@shell32.dll,-31415""
""PaneID""=""{43abf98b-89b8-472d-b9ce-e69b8229f019}""
""PaneVisibleProperty""=""PreviewPaneSizer_Visible""
""PolicyID""=""{17067f8d-981b-42c5-98f8-5bc016d4b073}""
[HKEY_CLASSES_ROOT\Directory\Background\shell\Windows.previewpane]
""CanonicalName""=""{1380d028-a77f-4c12-96c7-ea276333f982}""
""Description""=""@shell32.dll,-31416""
""Icon""=""shell32.dll,-16814""
""MUIVerb""=""@shell32.dll,-31415""
""PaneID""=""{43abf98b-89b8-472d-b9ce-e69b8229f019}""
""PaneVisibleProperty""=""PreviewPaneSizer_Visible""
""PolicyID""=""{17067f8d-981b-42c5-98f8-5bc016d4b073}""
[HKEY_CLASSES_ROOT\Drive\shell\Windows.previewpane]
""CanonicalName""=""{1380d028-a77f-4c12-96c7-ea276333f982}""
""Description""=""@shell32.dll,-31416""
""Icon""=""shell32.dll,-16814""
""MUIVerb""=""@shell32.dll,-31415""
""PaneID""=""{43abf98b-89b8-472d-b9ce-e69b8229f019}""
""PaneVisibleProperty""=""PreviewPaneSizer_Visible""
""PolicyID""=""{17067f8d-981b-42c5-98f8-5bc016d4b073}""
[HKEY_CLASSES_ROOT\LibraryFolder\background\shell\Windows.previewpane]
""CanonicalName""=""{1380d028-a77f-4c12-96c7-ea276333f982}""
""Description""=""@shell32.dll,-31416""
""Icon""=""shell32.dll,-16814""
""MUIVerb""=""@shell32.dll,-31415""
""PaneID""=""{43abf98b-89b8-472d-b9ce-e69b8229f019}""
""PaneVisibleProperty""=""PreviewPaneSizer_Visible""
""PolicyID""=""{17067f8d-981b-42c5-98f8-5bc016d4b073}""

;File Attribute Editing
[HKEY_CLASSES_ROOT\*\shell\Attributes]
""MUIVerb""=""Attributes""
""SubCommands""=""""
[HKEY_CLASSES_ROOT\*\Shell\Attributes\Shell\aShow]
""MUIVerb""=""Show current attributes""
[HKEY_CLASSES_ROOT\*\Shell\Attributes\Shell\aShow\command]
@=""cmd.exe /k attrib \""%1\""""
[HKEY_CLASSES_ROOT\*\Shell\Attributes\Shell\bReset]
""MUIVerb""=""Reset attributes""
[HKEY_CLASSES_ROOT\*\Shell\Attributes\Shell\bReset\command]
@=""attrib -r -a -s -h -i \""%1\""""
[HKEY_CLASSES_ROOT\*\Shell\Attributes\Shell\cReadOnlySet]
""CommandFlags""=dword:00000020
""MUIVerb""=""Set Read-only attribute""
[HKEY_CLASSES_ROOT\*\Shell\Attributes\Shell\cReadOnlySet\command]
@=""attrib +r \""%1\""""
[HKEY_CLASSES_ROOT\*\Shell\Attributes\Shell\dReadOnlyRemove]
""MUIVerb""=""Remove Read-only attribute""
[HKEY_CLASSES_ROOT\*\Shell\Attributes\Shell\dReadOnlyRemove\command]
@=""attrib -r \""%1\""""
[HKEY_CLASSES_ROOT\*\Shell\Attributes\Shell\eHiddenSet]
""CommandFlags""=dword:00000020
""MUIVerb""=""Set Hidden attribute""
[HKEY_CLASSES_ROOT\*\Shell\Attributes\Shell\eHiddenSet\command]
@=""attrib +h \""%1\""""
[HKEY_CLASSES_ROOT\*\Shell\Attributes\Shell\fHiddenRemove]
""MUIVerb""=""Remove Hidden attribute""
[HKEY_CLASSES_ROOT\*\Shell\Attributes\Shell\fHiddenRemove\command]
@=""attrib -h \""%1\""""
[HKEY_CLASSES_ROOT\*\Shell\Attributes\Shell\gSystemSet]
""CommandFlags""=dword:00000020
""MUIVerb""=""Set System attribute""
[HKEY_CLASSES_ROOT\*\Shell\Attributes\Shell\gSystemSet\command]
@=""attrib +s \""%1\""""
[HKEY_CLASSES_ROOT\*\Shell\Attributes\Shell\hSystemRemove]
""MUIVerb""=""Remove System attribute""
[HKEY_CLASSES_ROOT\*\Shell\Attributes\Shell\hSystemRemove\command]
@=""attrib -s \""%1\""""
[HKEY_CLASSES_ROOT\*\Shell\Attributes\Shell\iArchiveSet]
""CommandFlags""=dword:00000020
""MUIVerb""=""Set Archive attribute""
[HKEY_CLASSES_ROOT\*\Shell\Attributes\Shell\iArchiveSet\command]
@=""attrib +a \""%1\""""
[HKEY_CLASSES_ROOT\*\Shell\Attributes\Shell\jArchiveRemove]
""MUIVerb""=""Remove Archive attribute""
[HKEY_CLASSES_ROOT\*\Shell\Attributes\Shell\jArchiveRemove\command]
@=""attrib -a \""%1\""""

;Folder Attribute Editing
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes]
""SubCommands""=""""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\aShow]
""MUIVerb""=""Show current attributes""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\aShow\command]
@=""cmd.exe /k attrib \""%1\""""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\bShow]
""MUIVerb""=""Show attributes of this folder, subfolders and files""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\bShow\command]
@=""cmd.exe /k attrib \""%1\"" & attrib \""%1\\*.*\"" /s /d""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\cReset]
""MUIVerb""=""Reset attributes""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\cReset\command]
@=""cmd.exe /c attrib -r -a -s -h -i \""%1\""""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\dReset]
""MUIVerb""=""Reset attributes for this folder, subfolders and files""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\dReset\command]
@=""cmd.exe /c attrib -r -a -s -h -i \""%1\"" & attrib -r -a -s -h -i \""%1\\*.*\"" /s /d""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\eReadOnlySet]
""CommandFlags""=dword:00000020
""MUIVerb""=""Set Read-only attribute""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\eReadOnlySet\command]
@=""cmd.exe /c attrib +r \""%1\""""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\fReadOnlySet]
""MUIVerb""=""Set Read-only attribute to this folder, subfolders and files""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\fReadOnlySet\command]
@=""cmd.exe /c attrib +r \""%1\"" & attrib +r \""%1\\*.*\"" /s""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\gReadOnlyRemove]
""MUIVerb""=""Remove Read-only attribute""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\gReadOnlyRemove\command]
@=""cmd.exe /c attrib -r \""%1\""""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\hReadOnlyRemove]
""MUIVerb""=""Remove Read-only attribute from this folder and subfiles""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\hReadOnlyRemove\command]
@=""cmd.exe /c attrib -r \""%1\"" & attrib -r \""%1\\*.*\"" /s""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\iHiddenSet]
""CommandFlags""=dword:00000020
""MUIVerb""=""Set Hidden attribute""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\iHiddenSet\command]
@=""cmd.exe /c attrib +h \""%1\""""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\jHiddenSet]
""MUIVerb""=""Set Hidden attribute to this folder, subfolders and files""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\jHiddenSet\command]
@=""cmd.exe /c attrib +h \""%1\"" & attrib +h \""%1\\*.*\"" /s /d""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\kHiddenRemove]
""MUIVerb""=""Remove Hidden attribute""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\kHiddenRemove\command]
@=""cmd.exe /c attrib -h \""%1\""""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\lHiddenRemove]
""MUIVerb""=""Remove Hidden attribute from this folder, subfolders and files""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\lHiddenRemove\command]
@=""cmd.exe /c attrib -h \""%1\"" & attrib -h \""%1\\*.*\"" /s /d""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\mSystemSet]
""CommandFlags""=dword:00000020
""MUIVerb""=""Set System attribute""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\mSystemSet\command]
@=""cmd.exe /c attrib +s \""%1\""""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\oSystemRemove]
""MUIVerb""=""Remove System attribute""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\oSystemRemove\command]
@=""cmd.exe /c attrib -h \""%1\""""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\qArchiveSet]
""CommandFlags""=dword:00000020
""MUIVerb""=""Set Archive attribute""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\qArchiveSet\command]
@=""cmd.exe /c attrib +a \""%1\""""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\sArchiveRemove]
""MUIVerb""=""Remove Archive attribute""
[HKEY_CLASSES_ROOT\Directory\Shell\Attributes\Shell\sArchiveRemove\command]
@=""cmd.exe /c attrib -a \""%1\""""

;File Hashing
[HKEY_CLASSES_ROOT\*\shell\GetFileHash]
""MUIVerb""=""Hash""
""SubCommands""=""""
[HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\01SHA1]
""MUIVerb""=""SHA1""
[HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\01SHA1\command]
@=""powershell.exe -noexit get-filehash -literalpath '%1' -algorithm SHA1 | format-list""
[HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\02SHA256]
""MUIVerb""=""SHA256""
[HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\02SHA256\command]
@=""powershell.exe -noexit get-filehash -literalpath '%1' -algorithm SHA256 | format-list""
[HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\03SHA384]
""MUIVerb""=""SHA384""
[HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\03SHA384\command]
@=""powershell.exe -noexit get-filehash -literalpath '%1' -algorithm SHA384 | format-list""
[HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\04SHA512]
""MUIVerb""=""SHA512""
[HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\04SHA512\command]
@=""powershell.exe -noexit get-filehash -literalpath '%1' -algorithm SHA512 | format-list""
[HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\05MACTripleDES]
""MUIVerb""=""MACTripleDES""
[HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\05MACTripleDES\command]
@=""powershell.exe -noexit get-filehash -literalpath '%1' -algorithm MACTripleDES | format-list""
[HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\06MD5]
""MUIVerb""=""MD5""
[HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\06MD5\command]
@=""powershell.exe -noexit get-filehash -literalpath '%1' -algorithm MD5 | format-list""
[HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\07RIPEMD160]
""MUIVerb""=""RIPEMD160""
[HKEY_CLASSES_ROOT\*\shell\GetFileHash\shell\07RIPEMD160\command]
@=""powershell.exe -noexit get-filehash -literalpath '%1' -algorithm RIPEMD160 | format-list""

;Show Hide Extensions
[HKEY_CLASSES_ROOT\AllFilesystemObjects\shell\Windows.ShowFileExtensions]
""CommandStateSync""=""""
""Description""=""@shell32.dll,-37571""
""ExplorerCommandHandler""=""{4ac6c205-2853-4bf5-b47c-919a42a48a16}""
""MUIVerb""=""@shell32.dll,-37570""
[HKEY_CLASSES_ROOT\Directory\Background\shell\Windows.ShowFileExtensions]
""CommandStateSync""=""""
""Description""=""@shell32.dll,-37571""
""ExplorerCommandHandler""=""{4ac6c205-2853-4bf5-b47c-919a42a48a16}""
""MUIVerb""=""@shell32.dll,-37570""

;Advanced New Folder
[HKEY_CURRENT_USER\Software\Classes\CLSID\{B2B4A4D1-2754-4140-A2EB-9A76D9D7CDC6}]
""System.IsPinnedToNameSpaceTree""=-
[HKEY_CLASSES_ROOT\Directory\Background\shell\Windows.newfolder]
""CanonicalName""=""{E44616AD-6DF1-4B94-85A4-E465AE8A19DB}""
""CommandStateHandler""=""{3756e7f5-e514-4776-a32b-eb24bc1efe7a}""
""CommandStateSync""=""""
""Description""=""@shell32.dll,-31237""
""Icon""=""shell32.dll,-319""
""ImpliedSelectionModel""=dword:00000004
""InvokeCommandOnSelection""=dword:00000000
""MUIVerb""=""@shell32.dll,-31236""
""Position""=""Last""

;Screenshot Counter
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\ScreenshotIndex]
""muiverb""=""Reset Screenshot Index Counter""
""icon""=""DDORes.dll,-3061""
""Position""=""bottom""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\ScreenshotIndex\command]
@=""REG ADD HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer /V ScreenshotIndex /T REG_DWORD /D 1 /F""

;Magnifier
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Magnifier]
""SubCommands""=""""
""MUIVerb""=""Magnifier""
""icon""=""imageres.dll,-145""
""Position""=""Bottom""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Magnifier\Shell\01Lens]
""MUIVerb""=""Lens Magnify""
""Icon""=""imageres.dll,-145""
""Icon""=""imageres.dll,-145""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Magnifier\Shell\01Lens\command]
@=""C:\\Windows\\System32\\Magnify.exe /lens""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Magnifier\Shell\02Fullscreen]
""MUIVerb""=""Fullscreen Magnify""
""Icon""=""imageres.dll,-145""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Magnifier\Shell\02Fullscreen\command]
@=""C:\\Windows\\System32\\Magnify.exe /fullscreen""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Magnifier\Shell\03Docked]
""MUIVerb""=""Docked Magnify""
""Icon""=""imageres.dll,-145""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Magnifier\Shell\03Docked\command]
@=""C:\\Windows\\System32\\Magnify.exe /docked""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Magnifier\Shell\04Settings]
""MUIVerb""=""Magnifier Settings""
""Icon""=""imageres.dll,-145""
""SettingsURI""=""ms-settings:easeofaccess-magnifier""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Magnifier\Shell\04Settings\command]
""DelegateExecute""=""{556FF0D6-A1EE-49E5-9FA4-90AE116AD744}""

;Shutdown
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Shutdown]
""Icon""=""shell32.dll,-28""
""MUIVerb""=""Power""
""Position""=""Bottom""
""SubCommands""=""""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Shutdown\shell\001flyout]
""MUIVerb""=""Force apps to close, and shutdown PC with no time-out or warning""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Shutdown\shell\001flyout\command]
@=""shutdown /s /f /t 0""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Shutdown\shell\002flyout]
""MUIVerb""=""Shutdown PC with warning""
""CommandFlags""=dword:00000020
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Shutdown\shell\002flyout\command]
@=""shutdown /s""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Shutdown\shell\003flyout]
""MUIVerb""=""Turn off PC with no time-out or warning, but prompt to save any unsaved work""
""CommandFlags""=dword:00000020
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Shutdown\shell\003flyout\command]
@=""shutdown /p""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Shutdown\shell\004flyout]
""MUIVerb""=""Shutdown PC and prepares it for fast startup""
""CommandFlags""=dword:00000020
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Shutdown\shell\004flyout\command]
@=""shutdown /s /hybrid /t 0""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Shutdown\shell\005flyout]
""MUIVerb""=""Force apps to close, shutdown PC, and prepares it for fast startup""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Shutdown\shell\005flyout\command]
@=""shutdown /s /hybrid /f /t 0""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Shutdown\shell\006flyout]
""MUIVerb""=""Shutdown PC. On next boot, restart any opened registered apps""
""CommandFlags""=dword:00000020
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Shutdown\shell\006flyout\command]
@=""shutdown /sg /t 0""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Shutdown\shell\007flyout]
""MUIVerb""=""Slide to shut down PC""
""CommandFlags""=dword:00000020
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Shutdown\shell\007flyout\command]
@=""SlideToShutDown.exe""

;Restart
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Restart]
""Icon""=""shell32.dll,-16739""
""Position""=""Bottom""
""SubCommands""=""""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Restart\shell\001flyout]
""MUIVerb""=""Force apps to close, and full shutdown and restart PC with no time-out or warning""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Restart\shell\001flyout\command]
@=""shutdown /r /f /t 0""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Restart\shell\002flyout]
""MUIVerb""=""Full shutdown and restart PC with warning""
""CommandFlags""=dword:00000020
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Restart\shell\002flyout\command]
@=""shutdown /r""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Restart\shell\003flyout]
""MUIVerb""=""Full shutdown and restart PC. After rebooted, restart any opened registered apps.""
""CommandFlags""=dword:00000020
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Restart\shell\003flyout\command]
@=""shutdown /g /t 0""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Restart\shell\004flyout]
""MUIVerb""=""Restart to Advanced Startup Options""
""CommandFlags""=dword:00000020
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\Restart\shell\004flyout\command]
@=""shutdown /r /o /f /t 0""

;Edit With Photos
[HKEY_CLASSES_ROOT\AppX43hnxtbyyps62jhe9sqpdzxn1790zetc\Shell\ShellEdit]
""ActivatableClassId""=""App.AppX65n3t4j73ch7cremsjxn7q8bph1ma8jw.mca""
""Extended""=-
""ProgrammaticAccessOnly""=-
""PackageId""=""Microsoft.Windows.Photos_2017.39091.15730.0_x64__8wekyb3d8bbwe""
""ContractId""=""Windows.File""
""DesiredInitialViewState""=dword:00000000
@=""@{Microsoft.Windows.Photos_2017.39091.15730.0_x64__8wekyb3d8bbwe?ms-resource://Microsoft.Windows.Photos/Resources/EditWithPhotos}""
[HKEY_CLASSES_ROOT\AppX43hnxtbyyps62jhe9sqpdzxn1790zetc\Shell\ShellEdit\command]
""DelegateExecute""=""{4ED3A719-CEA8-4BD9-910D-E252F997AFC2}""

;Unblock Files
[HKEY_CLASSES_ROOT\*\shell\unblock]
""MUIVerb""=""Unblock""
""Extended""=-
[HKEY_CLASSES_ROOT\*\shell\unblock\command]
@=""powershell.exe Unblock-File -LiteralPath '%L'""
[HKEY_CLASSES_ROOT\Directory\shell\unblock]
""MUIVerb""=""Unblock""
""Extended""=-
""SubCommands""=""""
[HKEY_CLASSES_ROOT\Directory\shell\unblock\shell\001flyout]
""MUIVerb""=""Unblock files in this folder""
[HKEY_CLASSES_ROOT\Directory\shell\unblock\shell\001flyout\command]
@=""powershell.exe get-childitem -LiteralPath '%L' | Unblock-File""
[HKEY_CLASSES_ROOT\Directory\shell\unblock\shell\002flyout]
""MUIVerb""=""Unblock files in this folder and subfolders""
[HKEY_CLASSES_ROOT\Directory\shell\unblock\shell\002flyout\command]
@=""powershell.exe get-childitem -LiteralPath '%L' -recurse | Unblock-File""

;Windows Update
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsUpdateSettings]
""Icon""=""%SystemRoot%\\System32\\shell32.dll,-47""
""MUIVerb""=""Windows Update Settings""
""Position""=""Bottom""
""SubCommands""=""""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsUpdateSettings\shell\001flyout]
""Icon""=""%SystemRoot%\\System32\\bootux.dll,-1032""
""MUIVerb""=""Windows Update""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsUpdateSettings\shell\001flyout\command]
@=""explorer ms-settings:windowsupdate""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsUpdateSettings\shell\002flyout]
""Icon""=""%SystemRoot%\\System32\\bootux.dll,-1032""
""MUIVerb""=""Check for updates""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsUpdateSettings\shell\002flyout\command]
@=""explorer ms-settings:windowsupdate-action""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsUpdateSettings\shell\003flyout]
""Icon""=""%SystemRoot%\\System32\\bootux.dll,-1032""
""MUIVerb""=""Update history""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsUpdateSettings\shell\003flyout\command]
@=""explorer ms-settings:windowsupdate-history""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsUpdateSettings\shell\004flyout]
""Icon""=""%SystemRoot%\\System32\\bootux.dll,-1032""
""MUIVerb""=""Restart options""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsUpdateSettings\shell\004flyout\command]
@=""explorer ms-settings:windowsupdate-restartoptions""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsUpdateSettings\shell\005flyout]
""Icon""=""%SystemRoot%\\System32\\bootux.dll,-1032""
""MUIVerb""=""Advanced options""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsUpdateSettings\shell\005flyout\command]
@=""explorer ms-settings:windowsupdate-options""

;Power Options
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\PowerPlan]
""Icon""=""powercpl.dll""
""MUIVerb""=""Select Power Plan""
""Position""=""Bottom""
""SubCommands""=""""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\PowerPlan\shell\01menu]
""MUIVerb""=""Power Saver""
""Icon""=""powercpl.dll""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\PowerPlan\shell\01menu\command]
@=""powercfg.exe /setactive a1841308-3541-4fab-bc81-f71556f20b4a""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\PowerPlan\shell\02menu]
""MUIVerb""=""Balanced""
""Icon""=""powercpl.dll""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\PowerPlan\shell\02menu\command]
@=""powercfg.exe /setactive 381b4222-f694-41f0-9685-ff5bb260df2e""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\PowerPlan\shell\03menu]
""MUIVerb""=""High Performance""
""Icon""=""powercpl.dll""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\PowerPlan\shell\03menu\command]
@=""powercfg.exe /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\PowerPlan\shell\04menu]
""MUIVerb""=""Ultimate Performance""
""Icon""=""powercpl.dll""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\PowerPlan\shell\04menu\command]
@=""powercfg.exe /setactive e9a42b02-d5df-448d-aa00-03f14749eb61""
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\PowerPlan\shell\05menu]
""MUIVerb""=""Power Options""
""Icon""=""powercpl.dll""
""CommandFlags""=dword:00000020
[HKEY_CLASSES_ROOT\DesktopBackground\Shell\PowerPlan\shell\05menu\command]
@=""control.exe powercfg.cpl""

;Force Empty Recycle Bin
[HKEY_CLASSES_ROOT\Directory\Background\shell\empty]
""CommandStateHandler""=""{c9298eef-69dd-4cdd-b153-bdbc38486781}""
""Description""=""@shell32.dll,-31332""
""Icon""=""shell32.dll,-254""
""MUIVerb""=""@shell32.dll,-10564""
""Position""=""Bottom""
[HKEY_CLASSES_ROOT\Directory\Background\shell\empty\command]
""DelegateExecute""=""{48527bb3-e8de-450b-8910-8c4099cb8624}""

;Encryption
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
""EncryptionContextMenu""=dword:00000001

;Take Ownership
[HKEY_CLASSES_ROOT\*\shell\TakeOwnership]
@=""Take Ownership""
""HasLUAShield""=""""
""NoWorkingDirectory""=""""
""Position""=""middle""
[HKEY_CLASSES_ROOT\*\shell\TakeOwnership\command]
@=""powershell -windowstyle hidden -command \""Start-Process cmd -ArgumentList '/c takeown /f \\\""%1\\\"" && icacls \\\""%1\\\"" /grant *S-1-3-4:F /c /l & pause' -Verb runAs\""""
""IsolatedCommand""= ""powershell -windowstyle hidden -command \""Start-Process cmd -ArgumentList '/c takeown /f \\\""%1\\\"" && icacls \\\""%1\\\"" /grant *S-1-3-4:F /c /l & pause' -Verb runAs\""""
[HKEY_CLASSES_ROOT\Directory\shell\TakeOwnership]
@=""Take Ownership""
""AppliesTo""=""NOT (System.ItemPathDisplay:=\""C:\\Users\"" OR System.ItemPathDisplay:=\""C:\\ProgramData\"" OR System.ItemPathDisplay:=\""C:\\Windows\"" OR System.ItemPathDisplay:=\""C:\\Windows\\System32\"" OR System.ItemPathDisplay:=\""C:\\Program Files\"" OR System.ItemPathDisplay:=\""C:\\Program Files (x86)\"")""
""HasLUAShield""=""""
""NoWorkingDirectory""=""""
""Position""=""middle""
[HKEY_CLASSES_ROOT\Directory\shell\TakeOwnership\command]
@=""powershell -windowstyle hidden -command \""Start-Process cmd -ArgumentList '/c takeown /f \\\""%1\\\"" /r /d y && icacls \\\""%1\\\"" /grant *S-1-3-4:F /c /l /q & pause' -Verb runAs\""""
""IsolatedCommand""=""powershell -windowstyle hidden -command \""Start-Process cmd -ArgumentList '/c takeown /f \\\""%1\\\"" /r /d y && icacls \\\""%1\\\"" /grant *S-1-3-4:F /c /l /q & pause' -Verb runAs\""""
[HKEY_CLASSES_ROOT\*\shell\runas]
@=""Take Ownership""
""NoWorkingDirectory""=""""
[HKEY_CLASSES_ROOT\*\shell\runas\command]
@=""cmd.exe /c takeown /f \""%1\"" && icacls \""%1\"" /grant administrators:F""
""IsolatedCommand""=""cmd.exe /c takeown /f \""%1\"" && icacls \""%1\"" /grant administrators:F""
[HKEY_CLASSES_ROOT\Directory\shell\runas]
@=""Take Ownership""
""NoWorkingDirectory""=""""
[HKEY_CLASSES_ROOT\Directory\shell\runas\command]
@=""cmd.exe /c takeown /f \""%1\"" /r /d y && icacls \""%1\"" /grant administrators:F /t""
""IsolatedCommand""=""cmd.exe /c takeown /f \""%1\"" /r /d y && icacls \""%1\"" /grant administrators:F /t""
[HKEY_CLASSES_ROOT\*\shell\runas]
@=""Take Ownership""
""NoWorkingDirectory""=""""
[HKEY_CLASSES_ROOT\*\shell\runas\command]
@=""cmd.exe /c takeown /f \""%1\"" && icacls \""%1\"" /grant administrators:F""
""IsolatedCommand""=""cmd.exe /c takeown /f \""%1\"" && icacls \""%1\"" /grant administrators:F""
[HKEY_CLASSES_ROOT\Directory\shell\runas]
@=""Take Ownership""
""NoWorkingDirectory""=""""
[HKEY_CLASSES_ROOT\Directory\shell\runas\command]
@=""cmd.exe /c takeown /f \""%1\"" /r /d y && icacls \""%1\"" /grant administrators:F /t""
""IsolatedCommand""=""cmd.exe /c takeown /f \""%1\"" /r /d y && icacls \""%1\"" /grant administrators:F /t"""
Start-Sleep 1
Write-Output "Merging."
Reg import C:\Users\Temp.reg

Write-Output "Uninstalling ads. You can reinstall these later through the Microsoft Store, Winget, or Chocolatey."
$apps = @(
  "*2FE3CB00.PicsArt-PhotoStudio*"
  "*46928bounde.EclipseManager*"
  "*4DF9E0F8.Netflix*"
  "*613EBCEA.PolarrPhotoEditorAcademicEdition*"
  "*7EE7776C.LinkedInforWindows*"
  "*89006A2E.AutodeskSketchBook*"
  "*9E2F88E3.Twitter*"
  "*A278AB0D.DisneyMagicKingdoms*"
  "*A278AB0D.MarchofEmpires*"
  "*ActiproSoftwareLLC*"
  "*ActiproSoftwareLLC.562882FEEB491*"
  "*Adobe*"
  "*AdobeSystemsIncorporated.AdobePhotoshopExpress*"
  "*CAF9E577.Plex*"
  "*CandyCrush*"
  "*ClearChannel*"
  "*ClearChannelRadioDigital.iHeartRadio*"
  "*CountryEscape*"
  "*D52A8D61.FarmVille2CountryEscape*"
  "*CyberLink*"
  "*DB6EA5DB.CyberLinkMediaSuiteEssentials*"
  "*Disney*"
  "*Dolby*"
  "*DolbyLaboratories.DolbyAccess*"
  "*Drawboard*"
  "*Drawboard.DrawboardPDF*"
  "*Duolingo*"
  "*Duolingo-LearnLanguagesforFree*"
  "*Eclipse*"
  "*EclipseManager*"
  "*Facebook*"
  "*Facebook.Facebook*"
  "*Fitbit*"
  "*Fitbit.FitbitCoach*"
  "*Flare*"
  "*FlaregamesGmbH.RoyalRevolt2*"
  "*Flipboard*"
  "*Flipboard.Flipboard*"
  "*GAMELOFT*"
  "*GAMELOFTSA.Asphalt8Airborne*"
  "*Keeper*"
  "*KeeperSecurityInc.Keeper*"
  "*King*"
  "*King.com.BubbleWitch3Saga*"
  "*King.com.CandyCrushSaga*"
  "*King.com.CandyCrushSodaSaga*"
  "*King.com.FarmHeroesSaga*"
  "*King.com.CandyCrushFriends*"
  "*Minecraft*"
  "*NORDCURRENT*"
  "*NORDCURRENT.COOKINGFEVER*"
  "*Pandora*"
  "*PandoraMediaInc.29680B314EFC2*"
  "*Playtika*"
  "*Playtika.CaesarsSlotsFreeCasino*"
  "*Royal*"
  "*Shazam*"
  "*ShazamEntertainmentLtd.Shazam*"
  "*Sling*"
  "*SlingTVLLC.SlingTV*"
  "*Spotify*"
  "*SpotifyAB.SpotifyMusic*"
  "*Sway*"
  "*TheNewYorkTimes*"
  "*TheNewYorkTimes.NYTCrossword*"
  "*Thumbmunkeys*"
  "*ThumbmunkeysLtd.PhototasticCollage*"
  "*TuneIn*"
  "*TuneIn.TuneInRadio*"
  "*Twitter*"
  "*WinZip*"
  "*WinZipComputing.WinZipUniversal*"
  "*Wunderkinder.Wunderlist*"
  "*Wunderlist*"
  "*XINGAG.XING*"
  "*XING*"
)
foreach ($app in $apps) {
  Write-Output "Trying to remove $app"
  Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers
  Get-AppXProvisionedPackage -Online |
  Where-Object DisplayName -EQ $app |
  Remove-AppxProvisionedPackage -Online
}

Write-Output "Installing Winget."
Add-AppXPackage https://github.com/microsoft/winget-cli/releases/download/v1.3.2091/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
Write-Output "Installing useful stuff with Winget."
$packages = @(
  "Microsoft.DirectX"
  "Microsoft.Edge"
  "Microsoft.Git"
  "Microsoft.VCRedist.2005.x86"
  "Microsoft.VCRedist.2005.x64"
  "Microsoft.VCRedist.2008.x86"
  "Microsoft.VCRedist.2008.x64"
  "Microsoft.VCRedist.2010.x86"
  "Microsoft.VCRedist.2010.x64"
  "Microsoft.VCRedist.2012.x86"
  "Microsoft.VCRedist.2012.x64"
  "Microsoft.VCRedist.2013.x86"
  "Microsoft.VCRedist.2013.x64"
  "Microsoft.VCRedist.2015+.x86"
  "Microsoft.VCRedist.2015+.x64"
  "Microsoft.DotNet.DesktopRuntime.3_1"
  "Microsoft.DotNet.DesktopRuntime.5"
  "Microsoft.DotNet.DesktopRuntime.6"
)
foreach ($package in $packages) {
  Write-Output "Trying to install $package"
  winget install $package -h -e -s winget
}

Write-Output "Eating Chocolate. Mmmmmh."
Invoke-Expression ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
choco feature enable -n allowGlobalConfirmation
choco upgrade chocolatey
$chocos = @(
  "chocolatey-core.extension"
  "chocolatey-compatibility.extension"
  "chocolatey-windowsupdate.extension"
  "chocolatey-visualstudio.extension"
  "chocolatey-dotnetfx.extension"
  "dotnetfx"
  "dotnetcore"
  "dotnetcore3-desktop-runtime"
)
foreach ($choco in $chocos) {
  Write-Output "Trying to install $choco"
  choco install $choco -y
}

Write-Output "Wiping junk folders."
cleanmgr /sagerun:1 | out-Null
$junks = @(
  "C:\ProgramData\Microsoft\Windows\SystemData"
  "C:\Windows\Temp\*"
  "C:\OneDriveTemp\"
  "C:\PerfLogs\"
)
foreach ($junk in $junks) {
  Write-Output "Trying to remove $junk"
  Remove-Item "$junk" -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Output "Rebooting Explorer.exe. TaskKill will be used instead of Stop-Process due to permission issues."
taskkill /F /IM explorer.exe
Start-Process "explorer.exe"

Start-Process https://raw.githubusercontent.com/FlarosOverfield/Windows10SuperCharger/trainer/LICENSE
Write-Output "All tasks completed! Feel free to close this window."
timeout /t 43210 /nobreak