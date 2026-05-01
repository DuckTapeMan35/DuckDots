#!/usr/bin/env bash
A_1080=400
B_1080=400

# Check if wlogout is already running
if pgrep -x "wlogout" > /dev/null; then
    pkill -x "wlogout"
    exit 0
fi

# Get primary monitor resolution (using xrandr for MangoWM)
resolution=$(xrandr --query | grep -w connected | grep -w primary | awk '{print $4}' | cut -d'+' -f1)
if [ -z "$resolution" ]; then
    # Fallback to first connected monitor if no primary
    resolution=$(xrandr --query | grep -w connected | head -n1 | awk '{print $3}' | cut -d'+' -f1)
fi

# Extract height from resolution (e.g., "1920x1080")
height=$(echo "$resolution" | cut -d'x' -f2)

# Get scale factor (MangoWM doesn't have built-in scaling like Hyprland)
# You can set this manually or try to detect from X settings
scale=$(xrdb -query | grep -i "Xft.dpi" | awk '{print $2}')
if [ -z "$scale" ]; then
    scale=96  # Default DPI
fi

# Calculate scale factor (96 DPI = 1.0 scale)
scale_factor=$(echo "scale=2; $scale / 96.0" | bc)

# If bc not available or scale is 96, default to 1.0
if [ -z "$scale_factor" ] || [ "$scale" = "96" ]; then
    scale_factor=1.0
fi

# Calculate T and B values
T=$(awk "BEGIN {printf \"%.0f\", $A_1080 * 1080 * $scale_factor / $height}")
B=$(awk "BEGIN {printf \"%.0f\", $B_1080 * 1080 * $scale_factor / $height}")

# Launch wlogout
wlogout -C $HOME/.config/wlogout/style.css -l $HOME/.config/wlogout/layout \
        --protocol layer-shell -b 5 -T $T -B $B &
