{ config, pkgs, ... }:

{
  home.username = "jaga";
  home.homeDirectory = "/home/jaga";
  home.stateVersion = "25.11";
  programs.bash = {
    enable = true;
    shellAliases = {
      jaga = "echo HI JAGA!";     
    };
    profileExtra = ''
      if uwsm check may-start; then
        exec uwsm start hyprland.desktop
      fi
    '';
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  xdg.desktopEntries = {
    feh = {
      name = "feh";
      exec = "feh -. %u";
      mimeType = [ "image/jpeg" "image/png" ];
      terminal = false;
    };
    sxiv = {
      name = "sxiv";
      exec = "sxiv -a %u";
      mimeType = [ "image/gif" ];
      terminal = false;
    };
  };
}
