#!/usr/bin/env bash

virtwin=$(hyprctl workspaces | rg 'special:virtwin')

if [[ -n "$virtwin" ]]
then
  hyprctl dispatch togglespecialworkspace virtwin && pkill -SIGUSR1 '^waybar$'
else
  killall waybar && waybar &>/dev/null & disown
fi
