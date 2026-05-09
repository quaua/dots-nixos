{ config, pkgs, inputs, ... }:

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

      export EDITOR=nvim
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
      exec = "feh -. -Z %u";
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
      foreground = "#cccccc";
      background = "#121212";
      background_opacity = "0.9";
      selection_background = "#333333";
      cursor = "#cccccc";
      cursor_shape = "block";
      cursor_blink_interval = "0.5";
      confirm_os_window_close = 0;
      mouse_hide_wait = "1";
      enable_audio_bell = "no";
      open_url_with = "default";
      window_border_width = "1";
      window_margin_width = "5";
      color0 = "#333333";
      color8 = "#6a6a6a";
      color1 = "#cc3333";
      color9 = "#e51919";
      color2 = "#33cc33";
      color10 = "#19e519";
      color3 = "#cccc33";
      color11 = "#e5e519";
      color4 = "#3333cc";
      color12 = "#1919e5";
      color5 = "#cc33cc";
      color13 = "#e519e5";
      color6 = "#33cccc";
      color14 = "#19e5e5";
      color7 = "#cccccc";
      color15 = "#e5e5e5";
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

  programs.rofi = {
    enable = true;

    extraConfig = {
      font = "JetBrainsMono Nerd Font 12";
      show-icons = true;
      icon-theme = "MoreWaita";
      drun-display-format = "{name}";
      display-drun = "";
    };

    theme = let
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "*" = {
        my-bg = mkLiteral "#121212CC";
        my-fg = mkLiteral "#cccccc";
	txtcolor = mkLiteral "#121212";
	text-color = mkLiteral "@my-fg";
        background-color = mkLiteral "transparent";
      };

      "window" = {
        width = mkLiteral "960px";
        background-color = mkLiteral "@my-bg";
        border = mkLiteral "2px";
        border-color = mkLiteral "@my-fg";
        border-radius = mkLiteral "4px";
	# gap between apps and border of rofi
	padding = mkLiteral "20px"; 
      };

      "listview" = {
        # gap between apps
        spacing = mkLiteral "5px";
        # gap between apps and search bar
        margin = mkLiteral "10px 0 0 0"; 
      };

      "element" = {
        # gap between name of app and its box
        padding = mkLiteral "4px 6px";
      };

      "element selected" = {
        background-color = mkLiteral "@my-fg";
        text-color = mkLiteral "@txtcolor";
      };
  
      "element-text" = {
        text-color = mkLiteral "inherit";
      };
    };
  };
  #home.file."DEST".source = SOURCE;
}
