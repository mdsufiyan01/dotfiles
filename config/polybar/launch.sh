#!/bin/bash

killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 0.5; done

launch_polybar() {
  local bar_name="$1"
  local config_path="$2"
  polybar "$bar_name" -c "$config_path" & disown
}

config_dir="$HOME/.config/polybar"

hdmi_connected=$(xrandr -q | grep 'HDMI-1-0 connected' || echo "")

launch_polybar laptop "$config_dir/config.ini"

if [[ -n "$hdmi_connected" ]]; then
  launch_polybar external "$config_dir/config.ini"
  notify-send "External Monitor Detected" "Polybar launched on both screens."
fi