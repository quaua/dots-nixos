{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "reaper";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Almaty";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "kk_KZ.UTF-8";
    LC_IDENTIFICATION = "kk_KZ.UTF-8";
    LC_MEASUREMENT = "kk_KZ.UTF-8";
    LC_MONETARY = "kk_KZ.UTF-8";
    LC_NAME = "kk_KZ.UTF-8";
    LC_NUMERIC = "kk_KZ.UTF-8";
    LC_PAPER = "kk_KZ.UTF-8";
    LC_TELEPHONE = "kk_KZ.UTF-8";
    LC_TIME = "kk_KZ.UTF-8";
  };

  users.users.jaga = {
    isNormalUser = true;
    description = "jaga";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    neovim
    git
    kitty
    swaybg
    firefox
    spotify
    vesktop
    swaynotificationcenter
    quickshell
    rofi
    adwaita-icon-theme
    nwg-look
    yazi
    pavucontrol
    steam
    vlc
    feh
    sxiv
    kdePackages.dolphin
    kdePackages.qtsvg
  ];
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  system.stateVersion = "25.11";
  #
  # NVIDIA
  #
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable; # Same as production (nvidia driver version)
  hardware.graphics.enable = true; # Enable OpenGL
  hardware.nvidia = {
    modesetting.enable = true; # modesetting is required
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true; # Use open source drivers
    #nvidiaSettings = true; # to enable nvidia-settings
  };
  #
  # TTY AUTOLOGIN 
  #
  services.getty.autologinUser = "jaga";
  #
  # HYPRLAND
  #
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = false;
  };
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Hint electron apps to use wayland
  };
  #
  # NIX EXPERIMENTAL
  #
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  #
  # SHELL ALIASES
  #
  environment.shellAliases = {
    nrsf = "sudo nixos-rebuild switch --flake /etc/nixos#reaper";
  };
  #
  # AUDIO
  #
  security.rtkit.enable = true; # Enable RealtimeKit for audio purposes
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
}
