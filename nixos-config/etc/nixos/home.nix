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
    bashrcExtra = ''
      function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d ''' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
      }
    '';
    profileExtra = ''
      if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
        exec start-hyprland
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
