#!/bin/bash

killall -9 picom polybar dunst

~/.config/polybar/launch.sh --hack
~/.config/polybar/hack/scripts/pywal.sh ~/Pictures/wallpaper3.png

# Path to your pywal generated colors.json file
COLOR_FILE="$HOME/.cache/wal/colors.json"

# Read colors from pywal's colors.json and extract them
background=$(jq -r '.special.background' "$COLOR_FILE")
foreground=$(jq -r '.special.foreground' "$COLOR_FILE")
color0=$(jq -r '.colors.color0' "$COLOR_FILE")
color1=$(jq -r '.colors.color1' "$COLOR_FILE")
color2=$(jq -r '.colors.color2' "$COLOR_FILE")
color3=$(jq -r '.colors.color3' "$COLOR_FILE")
color4=$(jq -r '.colors.color4' "$COLOR_FILE")
color5=$(jq -r '.colors.color5' "$COLOR_FILE")
color6=$(jq -r '.colors.color6' "$COLOR_FILE")
color7=$(jq -r '.colors.color7' "$COLOR_FILE")
color8=$(jq -r '.colors.color8' "$COLOR_FILE")

color9=$(jq -r '.colors.color9' "$COLOR_FILE")
color10=$(jq -r '.colors.color10' "$COLOR_FILE")
color11=$(jq -r '.colors.color11' "$COLOR_FILE")
color12=$(jq -r '.colors.color12' "$COLOR_FILE")
color13=$(jq -r '.colors.color13' "$COLOR_FILE")
color14=$(jq -r '.colors.color14' "$COLOR_FILE")
color15=$(jq -r '.colors.color15' "$COLOR_FILE")
altwhite="$foreground"  # Use foreground as altwhite (optional)

# Path to dunstrc file
DUNSTRC_FILE="/home/duck/.config/dunst/dunstrc"

# Append the original dunstrc file with the new colors
cat <<EOF >> "$DUNSTRC_FILE"

[urgency_low]
    background = "$background"
    foreground = "$foreground"
    frame_color = "$color3"
    timeout = 10
    default_icon = dialog-information

[urgency_normal]
    background = "$background"
    foreground = "$foreground"
    frame_color = "$color3"
    timeout = 10
    override_pause_level = 30
    default_icon = dialog-information

[urgency_critical]
    background = "$background"
    foreground = "$foreground"
    frame_color = "$color3"
    timeout = 0
    override_pause_level = 60
    default_icon = dialog-warning
EOF

dunst &

#Set discord theme
pywal-discord -p ~/.config/vesktop/themes -t duck

# Restart Polybar and picom
polybar main &
picom &

#change keyboard color
polychromatic-cli -d keyboard -o static -c "$color1"

#apply spotify theme
spicetify apply