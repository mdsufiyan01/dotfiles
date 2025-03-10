#!/bin/bash

# Path to the video file you want to play
video_path="/home/cha/Videos/welcome.mp4"

# Play the video in fullscreen mode
mpv --fullscreen --no-border --really-quiet --loop-file=inf "$video_path" &

# Get the process ID of mpv
mpv_pid=$!

# Play the video for 10 seconds (adjust as needed)
sleep 5

# Kill the mpv process to stop the video
kill $mpv_pid

