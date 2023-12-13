# WARNING: THIS IS NOW DEPRECATED FOR PUBLIC USE. USE https://github.com/undergroundwires/privacy.sexy OR https://github.com/builtbybel/privatezilla INSTEAD TO CREATE YOUR VERY OWN SCRIPT. YOU CAN STILL USE THIS SCRIPT, BUT IT MIGHT HAVE SETTINGS THAT NO ONE WANTS EXCEPT ME. DESCRIPTION BELOW.



## Starting from September 2023, Windows 10 AND Windows 11 will automatically try to revert changes in the registry to default. This is because the average Windows user is braindead and installs ''debloat'' scripts on Github created by room temperature IQ individuals ~~coughcoughSycnexcoughcoughXyuetacoughcough~~ that remove important functionality that power users (and Windows itself) actually need, making the system a lot more unstable than it should be. This is a good thing, because many users who don't use debloat scripts at all will also damage their registry by installing malware such as Adobe Creative Cloud. But on the other hand, GOOD debloat scripts like this one will need to be assigned to Task Scheduler at each reboot in order to work properly.

### Description

This Powershell Script File entirely automates the configuration process that is USUALLY done right after installing Windows 10 Pro 22H2 or above, without removing **any** features. It's also used in my Windows 10 installation speedrun content. This Powershell file currently does ***NOT*** have an option to revert changes, so make sure you already have a Windows 10 installation USB Drive, if you ever change your mind.

This Powershell Script WILL redirect your entire user folder to the Z: Drive. This is a very common and effortless step to prevent C: failure induced data loss, but it comes with the downside that the Z: Drive must be plugged in at all times.

This script requires Admin, and is not designed for Windows 11. It might still work, but don't expect it to magically fix your Electron infested UI. It can be ran multiple times and does NOT require a restart. However, it will fail if multiple instances are running at once. You can close it and re-run it later, anytime. You can fork your own version on GitHub, on these conditions:

1. You must credit @ Miles Farber as per MIT License agreement
2. Everything must be packed into one .PS1 file that can be executed with Right Click on a stock Windows installation, without requiring any other files, UNLESS they're created OR downloaded by the .PS1 file itself.
3. **NO REMOVAL OF FEATURES**, that's not what this script is for. You can only disable them if the user can easily re-enable them (Such as the navigation pane)

### Installation

1. REMEMBER to disable "Windows Hello-only login" from the settings app, then lock (WIN + L) and log in again using your **Password**, NOT your **PIN**. This is required to fix SMB. This cannot be automated for security reasons.
2. Select this code: `Invoke-Expression ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/MilesFarber/Windows10SuperCharger/trainer/Windows10SuperCharger.ps1'))` 
3. Press CTRL + C, then WIN + X, then A, then LEFT, then ENTER, then CTRL + V, then ENTER. (This will copy the code, open Powershell/Terminal as Admin, confirm UAC, paste the code, and execute it.)
4. ?????
5. PROFIT!!!1

Alternatively, you can simply download the .PS1 file, place it on your desktop (or any folder that doesn't require admin permissions), and run it. It can take between 10 to 60 minutes depending on your storage speed, internet connection speed, or processor speed.
