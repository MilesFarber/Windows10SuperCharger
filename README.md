# Welcome to Flaros Overfield's Windows 10 Super Charger

This Powershell Script File was created because too many ''debloat'' scripts on Github created by room temperature IQ individuals ~~coughcoughSycnexcoughcough~~ remove important functionality that power users (and Windows itself) actually need. It entirely automates the configuration process that is USUALLY done right after installing Windows 10 Pro 20H2 or above, without removing any features. It's also used in my Windows 10 installation speedrun content.

This script requires Admin, and is not designed for Windows 11. It might still work, but don't expect it to magically fix your electron infested UI. It can be ran multiple times and does NOT require a restart. However, it will fail if multiple instances are running at once. You can close it and re-run it later, anytime. You can fork your own version on GitHub, on these conditions:

1. You must credit @ Flaros Overfield as per MIT License agreement
2. Everything must be packed into one .PS1 file that can be executed with Right Click on a stock Windows installation, without requiring any other files, UNLESS they're created OR downloaded by the .PS1 file itself.
3. NO REMOVAL OF FEATURES, that's not what this script is for. You can only disable them if the user can easily re-enable them (Such as the navigation pane)

This Powershell Script WILL redirect your entire user folder to the Z: Drive. This is a very common and effortless step to prevent C: failure induced data loss, but it comes with the downside that the Z: Drive must be plugged in at all times. If you don't want this, please open this file with notepad and remove the batches of registry keys below 'Windows Registry Editor Version 5.00' that are labeled ''Move User folder to Z:\Documents.''. Do not remove any other batch. Again, you can also fork your own version of the Windows 10 Super Charger.

## Usage

Please confirm the requirements below have been met, as they can NOT be automated.

1. Every single driver must be up to date. This is required for obvious reasons. This cannot be automated for obvious reasons.
2. Your PortableApps drive, or any storage drive of your choice, MUST have a backup, and be mounted on Z:. You can use Disk Management or Map Network Drive to fix this. This cannot be automated because YOU have to choose which drive must become the Z: drive.
3. App Installer MUST be up to date from the Microsoft Store, and Windows 10 is updated to at least 20H2. This is required because this script uses Winget to automatically install .NET, VCRedist and other important runtimes required to run most programs. This cannot be automated in any way, shape or form due to how the Microsoft Store functions. This will be fixed in 22H2.
4. You must have logged in at least once with your full Password, without using PIN or Hello. this is required to fix SAMBA. This won't be automated for security reasons.
5. Your PC MUST be renamed properly. This is required to fix SAMBA. This cannot be automated because YOU have to choose what to name your PC, and it's good practice to not give it the same name as another PC in your household.

If everything is ready, perform these steps.

1. Press Win + X, then A to start Powershell with Admin. Paste this code: `Invoke-Expression ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/FlarosOverfield/Windows10SuperCharger/trainer/Windows10SuperCharger.ps1'))`
2. ?????
3. PROFIT!!!1

Alternatively, you can simply download the .PS1 file, place it on your desktop (or any folder that doesn't require admin permissions), and run it. It can take between 10 to 60 minutes depending on your storage speed, internet connection speed, or processor speed.
