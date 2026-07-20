# nixos-config

My NixOS + Hyprland dots

Bar - Quickshell  
File Manager - Yazi  
Terminal - Kitty  
App Launcher - Rofi  
Browser - Zen  

## Installation

Clone repository then run this command ```./install.sh```.  
Keep in mind that this bash script is intented for first time installation and for rebuilding whole configuration.  
To make weather forecast work, you have to visit openweather website and get there API key, after that go to pythonScripts directory and paste API key. After you can run this command to specify which city to fetch. ```setweather cityName countryCode```  

## Known issues

mkOutOfStoreSymlink doesnt work, IT SEEMS TO WORK??? BUT STILL SHOWS SYMLINK TO NIX/STORE FOR SOME REASON  
Matugen spotify and GTK doesnt work  
Suspend doesnt work  
It has frame drops when switching between workspaces, probably just switch to niri. Too lazy to fix it  
Install bash script may break on fresh install  
When calendar updates to a next month and when you watching prev/next month from current one, month you currently watching can change without pressing any buttons.

## TODO

Add power menu in quickshell  
Rice lock screen  
Rice context menu in tray  
Clean up some stuff related to screenshot system  
Make yazi open as file chooser menu, if its possible  
Customize fastfetch  
Make live wallpaper switcher  
Make theme switcher when switching to a wallpaper via matugen and scripts  
Change terminal prompt via starship  
Tweak colors for yazi, neovim on matugen  
Make cursor auto apply at fresh install  
Add volume control quickshell bar  
Add volume binds  
Style swaync and add notification center and add notification sound  
Make automatic timezones and location change for system, if its possible on nixos  
Split shell.qml to different ones. workspaces.qml , time.qml , calendar.qml etc.
