#!/bin/bash

DISPLAY=":0" # Adjust if needed

# Get the connected output
OUTPUT=$(xrandr | grep " connected" | awk '{print $1}')

if [ -z "$OUTPUT" ]; then
    dunstify -r 9977 "Refresh Rate" "Error: No connected displays found."
    echo "Error: No connected displays found."
    exit 1
fi

XRR_COMMAND="xrandr --output $OUTPUT --rate"

POWER_STATE=$(cat /sys/class/power_supply/ACAD/online)

if [[ "$POWER_STATE" -eq 0 ]]; then
    if $XRR_COMMAND 60; then
        dunstify -r 9977 "Refresh Rate" "Switching to 60Hz (Battery)."
        echo "Refresh rate set to 60Hz (Battery)."
    else
        dunstify -r 9977 "Refresh Rate" "Error: Failed to set refresh rate to 60Hz."
        echo "Error: Failed to set refresh rate to 60Hz."
    fi
elif [[ "$POWER_STATE" -eq 1 ]]; then
    if $XRR_COMMAND 144; then
        dunstify -r 9977 "Refresh Rate" "Switching to 144Hz (AC)."
        echo "Refresh rate set to 144Hz (AC)."
    else
        dunstify -r 9977 "Refresh Rate" "Error: Failed to set refresh rate to 144Hz."
        echo "Error: Failed to set refresh rate to 144Hz."
    fi
else
    dunstify -r 9977 "Refresh Rate" "Could not determine power state."
    echo "Could not determine power state."
fi