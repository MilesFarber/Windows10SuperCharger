Set-ExecutionPolicy Unrestricted -Scope CurrentUser
$CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
if($CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
{
  $StartTime = Get-Date
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
	"CodecGuide.K-LiteCodecPack.Mega"
	"Discord.Discord"
	"FxSoundLLC.FxSound"
	"IObit.AdvancedSystemCare"
	"IObit.DriverBooster"
	"IObit.MalwareFighter"
	"Microsoft.AppInstaller"
	"Microsoft.DevHome"
	"Microsoft.DirectX"
	"Microsoft.DotNet.DesktopRuntime.10"
	"Microsoft.DotNet.DesktopRuntime.3_1"
	"Microsoft.DotNet.DesktopRuntime.5"
	"Microsoft.DotNet.DesktopRuntime.6"
	"Microsoft.DotNet.DesktopRuntime.7"
	"Microsoft.DotNet.DesktopRuntime.8"
	"Microsoft.DotNet.DesktopRuntime.9"
	"Microsoft.DotNet.DesktopRuntime.Preview"
	"Microsoft.Edge"
	"Microsoft.IronPython.3"
	"Microsoft.NuGet"
	"Microsoft.Office"
	"Microsoft.OneDrive"
	"Microsoft.PowerToys"
	"Microsoft.RemoteDesktopClient"
	"Microsoft.VCRedist.2005.x64"
	"Microsoft.VCRedist.2005.x86"
	"Microsoft.VCRedist.2008.x64"
	"Microsoft.VCRedist.2008.x86"
	"Microsoft.VCRedist.2010.x64"
	"Microsoft.VCRedist.2010.x86"
	"Microsoft.VCRedist.2012.x64"
	"Microsoft.VCRedist.2012.x86"
	"Microsoft.VCRedist.2013.x64"
	"Microsoft.VCRedist.2013.x86"
	"Microsoft.VCRedist.2015+.x64"
	"Microsoft.VCRedist.2015+.x86"
	"Microsoft.VisualStudioCodeInsiders"
	"Microsoft.WindowsTerminal"
	"Microsoft.WingetCreate"
	"Proton.ProtonDrive"
	"ProtonTechnologies.ProtonMailBridge"
	"ProtonTechnologies.ProtonVPN"
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
    "WindowsMediaPlayer"
)

Start-Process https://raw.githubusercontent.com/MilesFarber/Windows10SuperCharger/trainer/README.md
$pcname = Read-Host -Prompt "THIS IS YOUR LAST CHANCE TO DOUBLE CHECK THE README. If everything is ready, enter this PC's desired name to begin."
Rename-Computer -NewName $pcname -Force

Write-Output "SUPERCHARGING..."

Write-Output "Pausing Windows Update and uninstalling ads. You can reinstall any of these quickly through the Microsoft Store, Nuget, or Winget."
net stop wuauserv
Get-AppxPackage -AllUsers | where-object {$_.name -notlike "*store*"} | Remove-AppxPackage -ErrorAction SilentlyContinue

Write-Output "Fixing Power Plan and disabling Hibernation. Disabling Hibernation will be ran 3 times at strategic points during the script to avoid that one bug where it doesn't do anything."
powercfg /S 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg /setdcvalueindex SCHEME_CURRENT SUB_ENERGYSAVER ESBATTTHRESHOLD 100
powercfg /h off

Write-Output "Disabling useless sleep functions that were only meant for ARM processors. This has to go AFTER Power Plan fix to save correctly."
foreach ($sleeper in $sleepers) {
  powercfg /X $sleeper 0
}

Write-Output "Disabling SMBv1 to avoid EternalBlue because unfortunately we are STILL sharing oxygen with people running Windows XP in 2022."
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force

Write-Output "Setting Ethernet connections to Private and enabling Remote Desktop and File Sharing. This is required to fix SMB. If you see a red error here, your network is too sus and will be kept Public to avoid tracking."
Get-NetConnectionProfile | ForEach-Object {
	Set-NetConnectionProfile -InterfaceIndex $_.InterfaceIndex -NetworkCategory Private
}
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
Get-NetFirewallRule -DisplayGroup 'Network Discovery' | Set-NetFirewallRule -Profile 'Private, Domain' -Enabled true
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

Write-Output "Merging Registry Keys. Check the Z.Reg file in the GitHub repository for a description of what each payload does."
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/MilesFarber/Windows10SuperCharger/trainer/Z.reg" -OutFile "Z.reg"
reg import Z.reg

Write-Output "Installing NuGet and WinGet. If you see red errors here, you're fucked. WingetBackup is the only repository in existence that is currently storing a WORKING Winget package OUTSIDE of the Microsoft Store. You will have to download it from the Microsoft Store. There is absolutely no other way to do this, since Github now sometimes blocks all Powershell clients from automatically downloading certain filetypes, such as MSIXBundles."
wsreset -i
Install-PackageProvider -Name NuGet -Force
Install-Module -Name Microsoft.WinGet.Client -Force
Write-Output "Order 1."
Add-AppxPackage -Path https://github.com/MilesFarber/WingetBackup/raw/trainer/Microsoft.VCLibs.140.00.UWPDesktop_8wekyb3d8bbwe.Appx
Add-AppxPackage -Path https://github.com/MilesFarber/WingetBackup/raw/trainer/Microsoft.UI.Xaml.2.7_8wekyb3d8bbwe.Appx
Add-AppxPackage -Path https://github.com/MilesFarber/WingetBackup/raw/trainer/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
Write-Output "Order 2."
Add-AppxPackage -Path https://github.com/MilesFarber/WingetBackup/raw/trainer/Microsoft.UI.Xaml.2.7_8wekyb3d8bbwe.Appx
Add-AppxPackage -Path https://github.com/MilesFarber/WingetBackup/raw/trainer/Microsoft.VCLibs.140.00.UWPDesktop_8wekyb3d8bbwe.Appx
Add-AppxPackage -Path https://github.com/MilesFarber/WingetBackup/raw/trainer/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle

powercfg /h off

Write-Output "Installing useful stuff with Winget and DISM."
foreach ($package in $packages) {
	$output = winget list $package | Out-String
	if ($output -match "No installed package found matching input criteria.") {
		Write-Output "$package is not installed. Attempting installation."
		winget install $package -h -e -s winget
	} else {
		Write-Output "$package is already installed."
	}
}
foreach ($feature in $features) {
	$featureState = (Get-WindowsOptionalFeature -Online -FeatureName $feature).State
	if ($featureState -eq 'Enabled') {
		Write-Output "$feature is already enabled."
	} else {
		Write-Output "Trying to enable $feature"
		DISM /Online /Enable-Feature /FeatureName:$feature /All /Quiet /NoRestart
	}
}

Write-Output "Wiping junk folders."
foreach ($junk in $junks) {
  Write-Output "Trying to remove $junk"
  Remove-Item "$junk" -Recurse -Force -ErrorAction SilentlyContinue
}
cleanmgr /sagerun:1 | out-Null
powercfg /h off

Write-Output "Rebooting Explorer.exe. TaskKill will be used instead of Stop-Process due to permission issues."
taskkill /F /IM explorer.exe
Start-Process "explorer.exe"

Start-Process https://raw.githubusercontent.com/MilesFarber/Windows10SuperCharger/trainer/LICENSE
$EndTime = Get-Date
$TotalTime = $EndTime - $StartTime
Write-Output "All tasks completed! The script wasted $($TotalTime.ToString()) of your life. Feel free to close this window, or wait 12 hours to automatically close it. HWID License activation tool will start now."
irm https://massgrave.dev/get | iex

timeout /t 43210 /nobreak