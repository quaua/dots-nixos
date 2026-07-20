#!/usr/bin/env bash
shopt -s extglob

sudo rm -rf /etc/nixos/!(hardware-configuration.nix)
sudo cp ./nixos/* /etc/nixos/
sudo rsync -a --exclude=".*" --exclude="nixos" --exclude="install.sh" --exclude="README.md" ../dots-nixos /etc/nixos/

sudo nixos-rebuild switch --flake /etc/nixos#reaper

awww img /etc/nixos/dots-nixos/wallpapers/ign_colorful.png
matugen color hex "#be616a"
hyprctl reload
