{ pkgs, hyprland, ... }: pkgs.writeShellApplication {
  name = "wofi-power";
  runtimeInputs = [ hyprland pkgs.wofi pkgs.swaylock pkgs.gawk ];
  text = ''
    if pgrep wofi -x; then
      killall wofi
    fi

    entries="󰌾  Lock\n⇠  Logout\n⏾  Suspend\n󰜉  Reboot\n⏻  Shutdown"

    selected=$(echo -e "$entries" | wofi --location=top_right --style=${./wofi-power.css} --width=120 --height=160 --show=dmenu --prompt=Power --define=layer=overlay --cache-file=/dev/null | awk '{print tolower($2)}')

    case $selected in
      lock)
        exec swaylock;;
      logout)
        exec hyprctl dispatch exit;;
      suspend)
        exec systemctl suspend;;
      reboot)
        exec systemctl reboot;;
      shutdown)
        exec systemctl poweroff -i;;
    esac
  '';
}
