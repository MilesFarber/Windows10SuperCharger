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

$sleepers = @(
	"monitor-timeout-ac"
	"monitor-timeout-dc"
	"disk-timeout-ac"
	"disk-timeout-dc"
	"standby-timeout-ac"
	"standby-timeout-dc"
	"hibernate-timeout-ac"
	"hibernate-timeout-dc"
)

$junks = @(
	"C:\Windows\Temp\"
	"C:\OneDriveTemp\"
	"C:\PerfLogs\"
	"C:\Temp\"
)

$packages = @(
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
  "Microsoft.DotNet.DesktopRuntime.7"
)

$features = @(
    "DirectPlay"
    "HypervisorPlatform"
    "Internet-Explorer-Optional-amd64"
    "LegacyComponents"
    "MediaPlayback"
    "Microsoft-Hyper-V"
    "Microsoft-Hyper-V-All"
    "Microsoft-Hyper-V-Hypervisor"
    "Microsoft-Hyper-V-Management-Clients"
    "Microsoft-Hyper-V-Management-PowerShell"
    "Microsoft-Hyper-V-Services"
    "Microsoft-Hyper-V-Tools-All"
    "Microsoft-Windows-Subsystem-Linux"
    "NetFX3"
    "NetFx4Extended-ASPNET45"
    "Printing-Foundation-Features"
    "Printing-Foundation-InternetPrinting-Client"
    "Printing-Foundation-LPDPrintService"
    "Printing-Foundation-LPRPortMonitor"
    "Printing-PrintToPDFServices-Features"
    "SmbDirect"
    "VirtualMachinePlatform"
    "Windows-Defender-ApplicationGuard"
    "Windows-Defender-Default-Definitions"
    "WindowsMediaPlayer"
)

Start-Process https://raw.githubusercontent.com/MilesFarber/Windows10SuperCharger/trainer/README.md
$pcname = Read-Host -Prompt "THIS IS YOUR LAST CHANCE TO DOUBLE CHECK THE README. If everything is ready, enter this PC's desired name to begin."
Write-Output "SUPERCHARGING..."
Write-Output "If you see a red error here, your PC name is already correct."
Rename-Computer -NewName $pcname -Force

Write-Output "Fixing Power Plan and disabling Hibernation and Windows Update service"
powercfg /S 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg /setdcvalueindex SCHEME_CURRENT SUB_ENERGYSAVER ESBATTTHRESHOLD 99
powercfg /h off
net stop wuauserv

Write-Output "Disabling useless sleep functions that were only meant for ARM processors. This has to go AFTER Power Plan fix to save correctly."
foreach ($sleeper in $sleepers) {
  powercfg /X $sleeper 0
}

Write-Output "Disabling SMBv1 to avoid EternalBlue because unfortunately we are STILL sharing oxygen with people running Windows XP in 2022."
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force

Write-Output "Setting Ethernet connections to Private and enabling Remote Desktop. This is required to fix SAMBA. If you see a red error here, you're on WiFi, and you will need to enable Private manually."
Set-NetConnectionProfile -Name "Network" -NetworkCategory Private
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

Write-Output "Merging Registry Keys. Check the Z.Reg file in the repository for a description of what each payload does."
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/MilesFarber/Windows10SuperCharger/trainer/Z.reg" -OutFile "Z.reg"
reg import Z.reg

Write-Output "Uninstalling ads. You can reinstall any of these quickly through the Microsoft Store, Nuget, or Winget."
Get-AppxPackage -AllUsers | where-object {$_.name –notlike "*store*"} | Remove-AppxPackage -ErrorAction SilentlyContinue

Write-Output "Wiping junk folders, pass 1."
foreach ($junk in $junks) {
  Write-Output "Trying to remove $junk"
  Remove-Item "$junk" -Recurse -Force -ErrorAction SilentlyContinue
}
cleanmgr /sagerun:1 | out-Null

Write-Output "Installing NuGet and WinGet. If you see red errors here, you're fucked. WingetBackup is the only repository in existence that is currently storing a WORKING Winget package OUTSIDE of the Microsoft Store. You will have to download it from the Microsoft Store. There is absolutely no other way to do this, since Github now blocks all Powershell clients from automatically downloading certain filetypes, such as MSIXBundles."
Install-PackageProvider -Name NuGet -Force
Install-Module -Name Microsoft.WinGet.Client -Force
Add-AppxPackage -Path https://github.com/MilesFarber/WingetBackup/raw/trainer/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
Add-AppxPackage -Path https://github.com/MilesFarber/WingetBackup/raw/trainer/Microsoft.UI.Xaml.2.7_8wekyb3d8bbwe.Appx
Add-AppxPackage -Path https://github.com/MilesFarber/WingetBackup/raw/trainer/Microsoft.VCLibs.140.00.UWPDesktop_8wekyb3d8bbwe.Appx

Write-Output "Installing useful stuff with Winget and DISM."
foreach ($package in $packages) {
  Write-Output "Trying to install $package"
  winget install $package -h -e -s winget
}
foreach ($feature in $features) {
  Write-Output "Trying to enable $feature"
  DISM /Online /Enable-Feature /FeatureName:$feature /All /Quiet /NoRestart
}

Write-Output "Wiping junk folders, pass 2."
foreach ($junk in $junks) {
  Write-Output "Trying to remove $junk"
  Remove-Item "$junk" -Recurse -Force -ErrorAction SilentlyContinue
}
cleanmgr /sagerun:1 | out-Null

Write-Output "Rebooting Explorer.exe. TaskKill will be used instead of Stop-Process due to permission issues."
taskkill /F /IM explorer.exe
Start-Process "explorer.exe"

Start-Process https://raw.githubusercontent.com/MilesFarber/Windows10SuperCharger/trainer/LICENSE
Write-Output "All tasks completed! Feel free to close this window, or wait 12 hours to automatically restart the system."
timeout /t 43210 /nobreak