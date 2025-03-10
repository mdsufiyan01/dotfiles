#!/bin/bash

# Function to check if polybar is running
is_polybar_running() {
  pgrep -x polybar > /dev/null
}

# Function to launch polybar instances
launch_polybar() {
  local bar_name="$1"
  local config_path="$2"
  polybar "$bar_name" -c "$config_path" & disown
}

config_dir="$HOME/.config/polybar"

# Check if polybar is running
if is_polybar_running; then
  # If running, kill it
  killall -q polybar
  while is_polybar_running; do
    sleep 0.5
  done
else
  # If not running, launch it
  hdmi_connected=$(xrandr -q | grep 'HDMI-1 connected' || echo "")

  launch_polybar laptop "$config_dir/config.ini"

  if [[ -n "$hdmi_connected" ]]; then
    launch_polybar external "$config_dir/config.ini"
  fi
fi