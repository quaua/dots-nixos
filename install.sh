#!/usr/bin/env bash

sudo rm -rf /etc/nixos/configuration.nix /etc/nixos/flake.nix /etc/nixos/home.nix && sudo cp -r ./nixos/* /etc/nixos/ && sudo nixos-rebuild switch --flake /etc/nixos#reaper
cp -r ./config/* ~/.config/

awww img ~/nixos-config/wallpapers/ign_colorful.png
matugen color hex "#be616a"
hyprctl reload
