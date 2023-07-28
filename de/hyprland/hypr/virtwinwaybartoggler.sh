#!/usr/bin/env bash

toggler() {
  waybar=$(hyprctl layers)
  case "$waybar" in
    *Layer\ level\ 2\ \(top\)\:*namespace\:\ waybar*Layer\ level\ 3\ \(overlay\)* )
      echo 'waybar is open'
      case $1 in
        off )
          echo 'closing waybar'
          pkill -SIGUSR1 waybar
          ;;
        on  )
          echo 'doing nothing'
          ;;
        *   )
          echo 'wrong toggler sig'
          ;;
      esac
      ;;
    * )
      echo 'waybar is closed'
      case $1 in
        on  )
          echo 'opening waybar'
          pkill -SIGUSR1 waybar
          ;;
        off )
          echo 'doing nothing'
          ;;
        *   )
          echo 'wrong toggler sig'
          ;;
      esac
      ;;
  esac
}

handle() {
  case $1 in
    activewindow\>\>virt-manager,win11* )
      echo $1
      toggler "off"
      ;;
    activewindow\>\>*                   ) 
      echo $1
      toggler "on"
      ;;
  esac
}

socat -U - UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done
