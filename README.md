# Welcome to Flaros Overfield's Windows 10 Super Charger.

This Powershell Script File was created because too many ''debloat'' scripts on Github created by room temperature IQ individuals remove important functionality that power users (and Windows itself) actually need. It entirely automates the configuration process that is USUALLY done right after installing Windows 10 Pro 20H2 or above, without removing any features. 

This script requires Admin, and is not designed for Windows 11. It might still work, but don't expect it to magically fix your taskbar. It can be ran multiple times and does NOT require a restart. However, it will fail if multiple instances are running at once. You can close it and re-run it later, anytime. You can fork your own version on GitHub, on these conditions:

* You must credit @ Flaros Overfield as per MIT License agreement
* Everything must be packed into one .PS1 file that can be executed with Right Click on a stock Windows installation, without any further action. 
* No external files allowed unless they're created OR downloaded by the .PS1 file itself.
* NO REMOVAL OF FEATURES, that's not what this script is for.

This Powershell Script WILL redirect your entire user folder to the Z: Drive. This is a very common and effortless step to prevent C: failure induced data loss, but it comes with the downside that the Z: Drive must be plugged in at all times. If you don't want this, please open this file with notepad and remove the first batch of registry keys below 'Windows Registry Editor Version 5.00', labeled Move User folder to Z:\Documents.. (Should be at line ~50.) This can take between 10 to 60 minutes depending on your storage speed, internet connection speed, or processor speed. 

# Usage

Please confirm the requirements below have been met, as they can NOT be automated.

* Your PortableApps drive, or any storage drive of your choice, MUST have a backup, and be mounted on Z:. You can use Disk Management to fix this.
* App Installer MUST be up to date from the Microsoft Store, and Windows 10 is updated to at least 20H2.
* Focus Assist, Sleep, and Storage Sense MUST be turned off. (Fix coming soon.)
* This Powershell file MUST be placed in your desktop.
* Standard Password Login MUST be enabled.
* Your PC MUST be renamed properly.

If everything is ready, simply download the .PS1 file, place it on your desktop, and run it.
