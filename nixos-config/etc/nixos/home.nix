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

  programs.yazi = {
    enable = true;
    keymap = {
      mgr.prepend_keymap = [
        {
	  on = [ "<C-n>" ];
	  run = "shell -- xdragon -a -x -i -T \"$@\"";
	}
      ];
    };
  };

  programs.neovim = {
    enable = true;
    extraConfig = ''
      set number relativenumber
    '';
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

  programs.kitty = {
    enable = true;
    shellIntegration.mode = "no-cursor";
    settings = {
      font_family = "JetBrainsMono Nerd Font";
      italic_font = "auto";
      bold_font = "auto";
      bold_italic_font = "auto";
      font_size = "12.0";
      foreground = "#ded0db";
      background = "#1a1a1a";
      selection_foreground = "#1a1a1a";
      selection_background = "#ded0db";
      cursor = "#ded0db";
      cursor_shape = "block";
      cursor_blink_interval = "0.5";
      confirm_os_window_close = 0;
      mouse_hide_wait = "0.0";
      enable_audio_bell = "no";
      open_url_with = "default";
      window_border_width = "1";
      window_margin_width = "5";
      active_border_color = "#ded0db";
      inactive_border_color = "#3b3b3b";
      color0 = "#262626";
      color8 = "#4d4d4d";
      color1 = "#ae4040";
      color9 = "#dc4c4c";
      color2 = "#3dab59";
      color10 = "#47d86c";
      color3 = "#a5ab64";
      color11 = "#d0d87a";
      color4 = "#8368aa";
      color12 = "#a480d7";
      color5 = "#ae5789";
      color13 = "#dc6aac";
      color6 = "#63a0ad";
      color14 = "#7ac9da";
      color7 = "#aaaaa6";
      color15 = "#d6d6d1";
    };
  };


  gtk = {
    enable = true;
    
    # Fonts
    font.name = "JetBrainsMono Nerd Font";
    font.package = pkgs.nerd-fonts.jetbrains-mono;
    
    #Icons
    iconTheme.name = "MoreWaita";
    iconTheme.package = pkgs.morewaita-icon-theme;
  };
}
