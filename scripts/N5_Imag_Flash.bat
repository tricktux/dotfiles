rem Updated on 2/12/2016 6:29:57 AM
rem Purpose dirty flash nexus 5 with latest google factory image
@echo off
echo.
echo ----- ANDROID WINDOWS UPGRADE W/O WIPING DATA -----
echo. MAKE SURE THAT YOU: 
REM echo 	-Make sure you do adb reboot bootloader before running the script
REM echo 	-to make the adb command global in windows add ;<Path to SDK platform-tools & tools folder
echo 	-FIX THE NAMES OF THE BOOTLOADER AND RADIO HERE ON THIS SCRIPT
echo 	-Are running script from inside extracted .tgz image
REM echo. 	-COPIED THE CF-Auto-Root-hammerhead-hammerhead-nexus5.img into this folder
REM echo 	-EXTRACTED image-hammerhead*.zip TO EXPOSE THE BOOT.IMG....
REM we dont use franco anymoreecho 	-READ FRANCO KERNEL FORUM TO SEE IF IT HAS ANY UPDATES FOR THE NEW ANDROID VERSION
REM echo 		-IF SO DOWNLOAD THE IMAGE AND COPY IT TO THIS FOLDER
echo	-After installation steps are done go to  recovery
echo	-Flash latest SU and ElementalX kernel express zip
echo 	-HAVE FUN IN LIFE :D 
echo Press Ctrl+C followed by Y to cancel !
echo.
pause
REM tools\fastboot-windows.exe oem unlock
REM tools\fastboot-windows.exe oem unlock
REM command to extract original file
REM 	tar -xvzf
REM command to extract zip file
unzip image*.zip

adb reboot bootloader

echo Is the phone in Bootloader mode?
echo Press Ctrl+C followed by Y to cancel !
pause

REM FIX EACH NAME OF BOOTLOADER AND SO ON FOR THE NEW NAMES
fastboot flash bootloader bootloader-hammerhead-hhz12k.img

REM REBOOTING BOOTLOADER THIS IS FOR WINDOWS
fastboot reboot-bootloader
ping -n 5 127.0.0.1 >nul

fastboot flash radio radio-hammerhead-m8974a-2.0.50.2.28.img

fastboot reboot-bootloader
ping -n 5 127.0.0.1 >nul

fastboot flash boot boot.img
fastboot flash cache cache.img
fastboot flash system system.img

REM fastboot boot CF-Auto-Root-hammerhead-hammerhead-nexus5.img
rem if you want to do anything past this point you have to wait like 10 minutes
rem for device to reboot completely and run adb reboot bootloader
rem you have to wait a long time because it not only reboots but also optimizes
rem all apps this takes a long time

echo.
echo It may take a minute or so for the red Android to appear. If it doesn't show up
echo at all, there may be a problem.
echo. ALL SET HERE
pause
rem fastboot reboot recovery
