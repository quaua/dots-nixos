#!/usr/bin/env bash

cp -r ./config/* $HOME/.config/ && hyprctl reload
cp -r ./wallpapers $HOME
sudo cp -r ./nixos/* /etc/nixos/ && sudo nixos-rebuild switch --flake /etc/nixos#reaper
matugen -t scheme-fidelity image $HOME/wallpapers/forest.png
