# nixos-config

My NixOS + Hyprland dots

Bar - Quickshell  
File Manager - Yazi  
Terminal - Kitty  
App Launcher - Rofi  
Browser - Zen  

## Installation

Clone repository in home directory then rename directory to "nixos-config".  
Then in nixos-config directory run this command ```./install.sh```.  
Keep in mind that this bash script is intented for first installation and for rebuilding whole configuration, also do not delete this directory because symlinks are dependant on this directory.

## Known issues

mkOutOfStoreSymlink doesnt work, IT SEEMS TO WORK??? BUT STILL SHOWS SYMLINK TO NIX/STORE FOR SOME REASON  
Matugen spotify and GTK doesnt work  
Suspend doesnt work  
It has frame drops when switching between workspaces, probably just switch to niri. Too lazy to fix it  
Install bash script doesnt work on fresh install  
Calendar doesnt update days in real time... probably   

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
Make weather city change simple way without coding python files  
Add calendar months switcher. i.e. make buttons that will scroll months  
Change paths in whole configuration, to avoid using nixos-config
