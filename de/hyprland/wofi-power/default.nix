{ pkgs, hyprland, swaylock ? pkgs.swaylock-effects , ... }: pkgs.writeShellApplication {
  name = "wofi-power";
  runtimeInputs = [ hyprland swaylock pkgs.wofi pkgs.gawk ];
  text = ''
    if pgrep wofi -x; then
      killall wofi
    fi

    entries="󰌾  Lock\n⇠  Logout\n⏾  Suspend\n󰜉  Reboot\n⏻  Shutdown"

    selected=$(echo -e "$entries" | wofi -i --location=top_right --style=${./wofi-power.css} --width=120 --height=160 --show=dmenu --prompt=Power --define=layer=overlay --cache-file=/dev/null | awk '{print tolower($2)}')

    

    case $selected in
      lock)
        sleep 0.5 ; exec swaylock;;
      logout)
        exec hyprctl dispatch exit;;
      suspend)
        sleep 0.5 ; exec systemctl suspend;;
      reboot)
        exec systemctl reboot;;
      shutdown)
        exec systemctl poweroff -i;;
    esac
  '';
}
