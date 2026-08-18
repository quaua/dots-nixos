{ config, pkgs, inputs, ... }:

let
in

{
  imports = [
  ];

  home.username = "jaga";
  home.homeDirectory = "/home/jaga";
  home.stateVersion = "25.11";
  
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d ''' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
      }

      export EDITOR=nvim

      setweather() {
        python ~/dots-nixos/pythonScripts/place.py "$1" "$2"
      }
    '';

    profileExtra = ''
    '';
  };

  programs.yazi = {
    enable = true;
    shellWrapperName = "y";
    keymap = {
      mgr.prepend_keymap = [
        {
	      on = [ "<C-n>" ];
	      run = "shell -- xdragon -a -x -i -T \"$@\"";
	    }
      ];
    };
    plugins = {
      full-border = pkgs.yaziPlugins.full-border;
      mediainfo = pkgs.yaziPlugins.mediainfo;
    };
  };

  programs.neovim = {
    enable = true;
    withPython3 = false;
    withRuby = false;
    initLua = ''
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.g.mapleader = " "
      vim.keymap.set({'n', 'x'}, '<leader>y', [["+y]], { desc = "Copy to system clipboard" })
      vim.keymap.set({'n', 'x'}, '<leader>p', [["+p]], { desc = "Paste from system clipboard" })
      vim.keymap.set({'n', 'x'}, '<leader>d', [["+d]], { desc = "Cut/Copy to system clipboard and delete" })

      vim.cmd("colorscheme matugen")
      vim.api.nvim_create_autocmd("Signal", {
        pattern = "SIGUSR1",
        command = "colorscheme matugen",
      })

      vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

      
  vim.opt.tabstop = 4
  vim.opt.shiftwidth = 4
  vim.opt.softtabstop = 4
  vim.opt.expandtab = true
    '';
  };

  xdg.desktopEntries = {
    "org.gnome.Loupe" = {
      name = "Loupe";
      exec = "loupe %F";
      mimeType = [ "image/jpeg" "image/png" "image/gif" "image/webp" "image/tiff" ];
      terminal = false;
    };
    vlc = {
      name = "VLC media player";
      exec = "vlc %U";
      icon = "vlc";
      categories = [ "AudioVideo" "Player" ];
      mimeType = [ "video/mp4" "video/mkv" "video/x-matroska" ];
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
      background_opacity = "1.0"; #0.4 DELETE LATER
      cursor_shape = "block";
      cursor_blink_interval = "0.5";
      confirm_os_window_close = 0;
      mouse_hide_wait = "1";
      enable_audio_bell = "no";
      open_url_with = "default";
      window_border_width = "1";
      window_margin_width = "5";
      background = "#0a0e14";
      hide_window_decorations = "yes";
    };
    extraConfig = ''
      include colors.conf
    '';
  };

  gtk = {
    enable = true;

    gtk4.extraCss = ''
      @import 'colors.css';
    '';
    gtk3.extraCss = ''
      @import 'colors.css';
    '';
    
    # Fonts
    font.name = "JetBrainsMono Nerd Font";
    font.package = pkgs.nerd-fonts.jetbrains-mono;
    
    #Icons
    iconTheme.name = "MoreWaita";
    iconTheme.package = pkgs.morewaita-icon-theme;
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
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

    theme = 
    let
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "@import" = "colors.rasi";
      "*" = {
        my-bg = mkLiteral "@bgcolor";
        my-fg = mkLiteral "@fgcolor";
	border-color = mkLiteral "@bordercolor";
	txtcolor = mkLiteral "@darktxtcolor";
	text-color = mkLiteral "@textcolor";
        background-color = mkLiteral "transparent";
      };

      "window" = {
        width = mkLiteral "660px";
        background-color = mkLiteral "@my-bg";
        border = mkLiteral "2px";
        border-color = mkLiteral "@border-color";
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

  programs.fastfetch = {
    enable = true;
    settings = {
        "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/master/doc/json_schema.json";
        logo = {
          type = "small";
        };

    modules = [
      "title"
      "separator"
      "os"
      "uptime"
      "packages"
      "de"
      "wm"
      "cpu"
      "gpu"
      "memory"
      "disk"
      "battery"
      "poweradapter"
      "colors"
    ];
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    
  };

  xdg.configFile."yazi/init.lua".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/dots-nixos/yaziconf/init.lua";
  xdg.configFile."yazi/yazi.toml".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/dots-nixos/yaziconf/yazi.toml";
  xdg.configFile."matugen".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/dots-nixos/matugenconf";
  xdg.configFile."quickshell".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/dots-nixos/config/quickshell";
  #xdg.configFile."niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/dots-nixos/config/niri/config.kdl";
  xdg.configFile."niri/config.kdl".source =
    pkgs.runCommand "niri-config-checked"
    {
      nativeBuildInputs = [ pkgs.niri ];
    }
    ''
      niri validate --config ${./dots-nixos/config/niri/config.kdl}
      cp ${./dots-nixos/config/niri/config.kdl} $out
    '';
}
