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
}
