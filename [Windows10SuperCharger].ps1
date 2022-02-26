Set-ExecutionPolicy Unrestricted -Scope CurrentUser
Function Get-RunAsAdministrator()
{
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
}

Get-RunAsAdministrator
Write-Output "Welcome to Flaros Overfield's Windows 10 Supercharger.

This Powershell Script File was created because too many ''debloat'' scripts on Github created by room temperature IQ individuals remove important functionality that power users (and windows itself) actually need. It entirely automates the configuration process that is USUALLY done right after installing Windows 10 Pro 20H2 or above. This script requires Admin, and is not designed for Windows 11. It might still work, but don't expect it to magically fix your taskbar. It can be ran multiple times and does NOT require a restart. However, it will fail if multiple instances are running at once. You can close it and re-run it later, anytime. You can fork your own version on GitHub, as long as you link to the original, and you do NOT remove important things such as Edge or Onedrive as that's not what this script is made for.

Please confirm the requirements below have been met, as they can NOT be automated.

  Your PortableApps drive, or any storage drive of your choice, MUST be mounted to Z: and have a backup. You can use Disk Management to fix this.
  App Installer MUST be up to date from the Microsoft Store, and Windows 10 is updated to at least 20H2.
  Focus Assist, Sleep, and Storage Sense MUST be turned off. (Fix coming soon.)
  This Powershell file MUST be placed in your desktop.
  Standard Password Login MUST be enabled.
  Your PC MUST be renamed properly.

If you missed any of these steps, CLOSE THIS WINDOW IMMEDIATELY.

This Powershell Script WILL redirect your entire user folder to the Z: Drive. This is a very common step to prevent C: failure induced data loss, but it comes with the downside that the Z: Drive must be plugged in at all times. If you don't want this, please open this file with notepad and remove the first batch of registry keys below 'Windows Registry Editor Version 5.00', labeled Move User folder to Z:\Documents.. (Should be at line ~50.) This can take between 10 to 60 minutes depending on your storage speed, internet connection speed, or processor speed. 

This is your last LAST chance to review the requirements!
"
pause

Write-Output "SUPERCHARGING..."

Write-Output "Setting Ethernet connections to Private."
Set-NetConnectionProfile -Name "Network" -NetworkCategory Private

Write-Output "If Temp REG file already exists, it will be deleted to avoid conflicts with Add-Content."
Set-Location C:\Users
Remove-Item -Path C:\Users\Temp.reg -Force
New-item -Path . -Name "Temp.reg"
Write-Output "Printing REG File. This Script will use Add-Content to a REG file in the user folder instead of using New-Item, because it makes it way easier for new users to review what changed, by opening the REG file in the user folder."
Add-Content C:\Users\Temp.reg "Windows Registry Editor Version 5.00

;Move User folder to Z:\Documents.
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders]
""AppData""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,\
  00,41,00,70,00,70,00,44,00,61,00,74,00,61,00,00,00
""Cache""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,74,\
  00,73,00,5c,00,52,00,65,00,63,00,65,00,6e,00,74,00,73,00,00,00
""Cookies""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,52,00,65,00,63,00,65,00,6e,00,74,00,73,00,00,00
""Desktop""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,44,00,65,00,73,00,6b,00,74,00,6f,00,70,00,00,00
""Favorites""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,46,00,61,00,76,00,6f,00,72,00,69,00,74,00,65,00,73,00,00,\
  00
""History""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,52,00,65,00,63,00,65,00,6e,00,74,00,73,00,00,00
""Local AppData""=hex(2):25,00,55,00,53,00,45,00,52,00,50,00,52,00,4f,00,46,00,\
  49,00,4c,00,45,00,25,00,5c,00,41,00,70,00,70,00,44,00,61,00,74,00,61,00,5c,\
  00,4c,00,6f,00,63,00,61,00,6c,00,00,00
""My Music""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,4d,00,75,00,73,00,69,00,63,00,00,00
""My Pictures""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,\
  00,74,00,73,00,5c,00,50,00,69,00,63,00,74,00,75,00,72,00,65,00,73,00,00,00
""My Video""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,56,00,69,00,64,00,65,00,6f,00,73,00,00,00
""NetHood""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,4c,00,69,00,6e,00,6b,00,73,00,00,00
""Personal""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,00,\
  00
""PrintHood""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,4c,00,69,00,6e,00,6b,00,73,00,00,00
""Programs""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,4c,00,69,00,6e,00,6b,00,73,00,00,00
""Recent""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,74,\
  00,73,00,5c,00,52,00,65,00,63,00,65,00,6e,00,74,00,73,00,00,00
""SendTo""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,74,\
  00,73,00,5c,00,4c,00,69,00,6e,00,6b,00,73,00,00,00
""Start Menu""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,\
  00,74,00,73,00,5c,00,4c,00,69,00,6e,00,6b,00,73,00,00,00
""Startup""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,4c,00,69,00,6e,00,6b,00,73,00,5c,00,53,00,74,00,61,00,72,\
  00,74,00,00,00
""Templates""=hex(2):58,00,3a,00,5c,00,44,00,6f,00,63,00,75,00,6d,00,65,00,6e,00,\
  74,00,73,00,5c,00,52,00,65,00,63,00,65,00,6e,00,74,00,73,00,00,00
""{374DE290-123F-4565-9164-39C4925E467B}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,44,00,6f,00,77,00,6e,00,6c,\
  00,6f,00,61,00,64,00,73,00,00,00
""{339719B5-8C47-4894-94C2-D8F77ADD44A6}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,50,00,69,00,63,00,74,00,75,\
  00,72,00,65,00,73,00,00,00
""{4C5C32FF-BB9D-43b0-B5B4-2D72E54EAAA4}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,53,00,61,00,76,00,65,00,64,\
  00,20,00,47,00,61,00,6d,00,65,00,73,00,00,00
""{56784854-C6CB-462b-8169-88E350ACB882}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,43,00,6f,00,6e,00,74,00,61,\
  00,63,00,74,00,73,00,00,00
""{7d1d3a04-debb-4115-95cf-2f29da2920da}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,52,00,65,00,63,00,65,00,6e,\
  00,74,00,73,00,00,00
""{bfb9d5e0-c6a9-404c-b2b2-ae6db6af4968}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,4c,00,69,00,6e,00,6b,00,73,\
  00,00,00
""{F42EE2D3-909F-4907-8871-4C22FC0BF756}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,44,00,6f,00,63,00,75,00,6d,\
  00,65,00,6e,00,74,00,73,00,00,00
""{0DDD015D-B06C-45D5-8C4C-F59713854639}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,50,00,69,00,63,00,74,00,75,\
  00,72,00,65,00,73,00,00,00
""{A0C69A99-21C8-4671-8703-7934162FCF1D}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,4d,00,75,00,73,00,69,00,63,\
  00,00,00
""{35286A68-3C57-41A1-BBB1-0EAE73D76C95}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,56,00,69,00,64,00,65,00,6f,\
  00,73,00,00,00
""{7D83EE9B-2244-4E70-B1F5-5393042AF1E4}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,44,00,6f,00,77,00,6e,00,6c,\
  00,6f,00,61,00,64,00,73,00,00,00
""{754AC886-DF64-4CBA-86B5-F7FBF4FBCEF5}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,44,00,65,00,73,00,6b,00,74,\
  00,6f,00,70,00,00,00
""{2112AB0A-C86A-4FFE-A368-0DE96E47012E}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,4d,00,75,00,73,00,69,00,63,\
  00,00,00
""{E25B5812-BE88-4BD9-94B0-29233477B6C3}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,50,00,69,00,63,00,74,00,75,\
  00,72,00,65,00,73,00,00,00
""{52A4F021-7B75-48A9-9F6B-4B87A210BC8F}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,4c,00,69,00,6e,00,6b,00,73,\
  00,00,00
""{491E922F-5643-4AF4-A7EB-4E7A138D8174}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,56,00,69,00,64,00,65,00,6f,\
  00,73,00,00,00
""{2B20DF75-1EDA-4039-8097-38798227D5B7}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,50,00,69,00,63,00,74,00,75,\
  00,72,00,65,00,73,00,00,00
""{7B0DB17D-9CD2-4A93-9733-46CC89022E7C}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,44,00,6f,00,63,00,75,00,6d,\
  00,65,00,6e,00,74,00,73,00,00,00
""{A990AE9F-A03B-4E80-94BC-9912D7504104}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,50,00,69,00,63,00,74,00,75,\
  00,72,00,65,00,73,00,00,00
""{008CA0B1-55B4-4C56-B8A8-4DE4B299D3BE}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,50,00,69,00,63,00,74,00,75,\
  00,72,00,65,00,73,00,00,00
""{31C0DD25-9439-4F12-BF41-7FF4EDA38722}""=hex(2):5a,00,3a,00,5c,00,44,00,6f,00,\
  63,00,75,00,6d,00,65,00,6e,00,74,00,73,00,5c,00,33,00,44,00,20,00,4f,00,62,\
  00,6a,00,65,00,63,00,74,00,73,00,00,00

;Automatically give important processes higher priority.
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
""NavPaneShowAllFolders""=dword:00000001
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

;Add a Take Ownership button to remove the infamous ''You don't have permission to open this file Hurr Durr''.
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

;Replace Settings in start menu with actual User Folders.
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
""WaitToKillAppTimeout""=""5000""
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

;Make it much easier to double click and trigger hover functions.
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

;Show Hibernation option in the Shutdown menu.
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

;Disable Automatic Windows Updates.
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

;Fix Network Drive not showing on Elevated Programs, enable Virtualization and display verbose Logon information.
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System]
""EnableLinkedConnections""=dword:00000001
""EnableVirtualization""=dword:00000001
""VerboseStatus""=dword:00000001

;Show all background apps in Taskbar all the time and show drive letters in front.
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer]
""EnableAutoTray""=dword:00000000
""UserSignedIn""=dword:00000001
""PostAppInstallTasksCompleted""=dword:00000001
""ShowDriveLettersFirst""=dword:00000004

;Stop automatically deleting thumbnail cache.
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache]
""Autorun""=dword:00000000
[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache]
""Autorun""=dword:00000000

;Enable WINDOWS+V History menu.
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Clipboard]
""EnableClipboardHistory""=dword:00000001
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System]
""AllowClipboardHistory""=-

;Force enable battery time estimation.
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power]
""EnergyEstimationEnabled""=dword:00000001
[HKEY_CURRENT_USER\Software\Microsoft\Shell\USB]
""NotifyOnWeakCharger""=dword:00000001

;Quickly invert screen with CTRL+Windows+C when legacy x86 programs don't have dark theme.
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\ColorFiltering]
""HotkeyEnabled""=dword:00000001
""Active""=dword:00000000
""FilterType""=dword:00000001

;Prevent SVCHosts from multiplying like rabbits.
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control]
""SvcHostSplitThresholdInKB""=dword:04000000
""WaitToKillServiceTimeout""=""1000""

;Show an Instant Encrypt button in the right click menu.
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
""EncryptionContextMenu""=dword:00000001

;Show Seconds and AM/PM in Taskbar.
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
""ShowSecondsInSystemClock""=dword:00000001

;Show more details during file operations
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager]
""EnthusiastMode""=dword:00000001

;Don't minimize all open windows when shaking a window around. Nyyyooooommm
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
""DisallowShaking""=dword:00000001

;Restore the Security Tab in Explorer.
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer]
""NoSecurityTab""=dword:00000000

;Start Snip & Sketch with PRNTSCRN.
[HKEY_CURRENT_USER\Control Panel\Keyboard]
""PrintScreenKeyForSnippingEnabled""=dword:00000001

;Remove the ugly AF Navigation Pane.
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Modules\GlobalSettings\Sizer]
""PageSpaceControlSizer""=hex:a0,00,00,00,00,00,00,00,00,00,00,00,ec,03,00,00

;Force enable camera usage notifications.
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\OEM\Device\Capture]
""NoPhysicalCameraLED""=dword:00000001

;Auto End Tasks during shutdown.
[HKEY_CURRENT_USER\Control Panel\Desktop]
""AutoEndTasks""=""1""

;Disable Auto BSOD Restart.
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CrashControl]
""AutoReboot""=dword:00000000

;Clear page file at shutdown.
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management]
""ClearPageFileAtShutdown""=dword:00000001

;Disable Startup delay.
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Serialize]
""StartupDelayInMSec""=dword:00000000

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

;Small Electron Taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
""TaskbarSi""=dword:00000000

;Force Enable Mixed Reality menu.
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Holographic]
""FirstRunSucceeded""=dword:00000001

;Enable automatic registry backup.
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Configuration Manager]
""EnablePeriodicBackup""=dword:00000001"

Write-Output "Merging."
Reg import C:\Users\Temp.reg

Write-Output "Uninstalling useless stuff. You can reinstall these later through the Microsoft Store, Winget, or Chocolatey."
$apps = @(
  "2FE3CB00.PicsArt-PhotoStudio"
  "46928bounde.EclipseManager"
  "4DF9E0F8.Netflix"
  "613EBCEA.PolarrPhotoEditorAcademicEdition"
  "6Wunderkinder.Wunderlist"
  "7EE7776C.LinkedInforWindows"
  "89006A2E.AutodeskSketchBook"
  "9E2F88E3.Twitter"
  "A278AB0D.DisneyMagicKingdoms"
  "A278AB0D.MarchofEmpires"
  "ActiproSoftwareLLC"
  "ActiproSoftwareLLC.562882FEEB491"
  "AdobeSystemsIncorporated.AdobePhotoshopExpress"
  "BubbleWitch3Saga"
  "CAF9E577.Plex"  
  "CandyCrush"
  "ClearChannelRadioDigital.iHeartRadio"
  "D52A8D61.FarmVille2CountryEscape"
  "D5EA27B7.Duolingo-LearnLanguagesforFree"
  "DB6EA5DB.CyberLinkMediaSuiteEssentials"
  "Disney"
  "Dolby"
  "DolbyLaboratories.DolbyAccess"
  "Drawboard.DrawboardPDF"
  "Duolingo-LearnLanguagesforFree"
  "EclipseManager"
  "Facebook"
  "Facebook.Facebook"
  "Fitbit.FitbitCoach"
  "FlaregamesGmbH.RoyalRevolt2"
  "Flipboard"
  "Flipboard.Flipboard"
  "GAMELOFTSA.Asphalt8Airborne"
  "KeeperSecurityInc.Keeper"
  "King.com.*"
  "King.com.BubbleWitch3Saga"
  "King.com.CandyCrushSaga"
  "King.com.CandyCrushSodaSaga"
  "Minecraft"
  "NORDCURRENT.COOKINGFEVER"
  "PandoraMediaInc"
  "PandoraMediaInc.29680B314EFC2"
  "Playtika.CaesarsSlotsFreeCasino"
  "Royal Revolt"
  "ShazamEntertainmentLtd.Shazam"
  "SlingTVLLC.SlingTV"
  "Spotify"
  "SpotifyAB.SpotifyMusic"
  "Sway"
  "TheNewYorkTimes.NYTCrossword"
  "ThumbmunkeysLtd.PhototasticCollage"
  "TuneIn.TuneInRadio"
  "Twitter"
  "WinZipComputing.WinZipUniversal"
  "Wunderlist"
  "XINGAG.XING"
)
foreach ($app in $apps) {
  Write-Output "Trying to remove $app"
  Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers
  Get-AppXProvisionedPackage -Online |
  Where-Object DisplayName -EQ $app |
  Remove-AppxProvisionedPackage -Online
}

Write-Output "Removing MSSTORE from Winget Sources because it generates conflicts with the standard Winget repository."
winget source remove msstore

Write-Output "Installing useful stuff. If this section is full of red errors, please update Windows to 20H2 and App Installer from the Microsoft Store, and try again."
$packages = @(
  "Microsoft.dotnet"
  "Microsoft.dotNetFramework"
  "Microsoft.dotnetPreview"
  "Microsoft.dotnetRuntime.3-x64"
  "Microsoft.dotnetRuntime.3-x86"
  "Microsoft.dotnetRuntime.4-x64"
  "Microsoft.dotnetRuntime.4-x86"
  "Microsoft.dotnetRuntime.5-x64"
  "Microsoft.dotnetRuntime.5-x86"
  "Microsoft.VC++2005Redist-x64"
  "Microsoft.VC++2005Redist-x86"
  "Microsoft.VC++2010Redist-x64"
  "Microsoft.VC++2010Redist-x86"
  "Microsoft.VC++2013Redist-x64"
  "Microsoft.VC++2013Redist-x86"
  "Microsoft.VC++2015Redist-x64"
  "Microsoft.VC++2015Redist-x86"
  "Microsoft.VC++2017Redist-x64"
  "Microsoft.VC++2017Redist-x86"
  "Microsoft.VC++2015-2022Redist-x64"
  "Microsoft.VC++2015-2022Redist-x86"
  "Microsoft.WindowsTerminal"
  "Microsoft.WingetCreate"
  "Microsoft.OneDrive"
  "Microsoft.Teams"
  "Microsoft.Edge"

  "K-LiteCodecPackBasic"
)
foreach ($package in $packages) {
  Write-Output "Trying to install $package"
  winget install $package
}

Write-Output "Cleaning up."
Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\OneDriveTemp\" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\PerfLogs\" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item %APPDATA%\Microsoft\Windows\Recent\AutomaticDestinations\*.automaticDestinations-ms -FORCE -ErrorAction SilentlyContinue
fsutil behavior set DisableLastAccess 1
fsutil behavior set EncryptPagingFile 0
cleanmgr /sagerun:1 | out-Null
Write-Output "Rebooting Explorer.exe. TaskKill will be used instead of Stop-Process due to permission issues."
taskkill /F /IM explorer.exe
Start-Process "explorer.exe"
$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys('^{ESCAPE}')

Write-Output "All tasks completed! Feel free to close this window."
Start-Sleep 43210