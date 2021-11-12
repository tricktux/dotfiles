
@echo off

:: Close chrome first
:: Even better is to go to the properties of Chrome and add  
:: --disk-cache-dir=R:\ChromeCache
:: This will delete current cache
rd /s "%userprofile%\AppData\Local\Google\Chrome\User Data\Default\Cache"
:: This will symlink it to RAM
mklink /j "%userprofile%\AppData\Local\Google\Chrome\User Data\Default\Cache" R:\Temp
