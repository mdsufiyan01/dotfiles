#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/.dotfiles/config/wallpaper"
THEME_FILE="$HOME/.dotfiles/config/polybar/scripts/rofi/wallpaper.rasi"
CACHE_FILE="$HOME/.cache/current_wallpaper"

# Gather all files into a sorted array
mapfile -t files < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f | sort)

if [ ${#files[@]} -eq 0 ]; then
    exit 1
fi

while true; do
    # Read the last selected wallpaper from cache
    last_wallpaper=""
    if [[ -f "$CACHE_FILE" ]]; then
        last_wallpaper=$(cat "$CACHE_FILE")
    fi

    # Find the index of the last selected wallpaper
    current_index=0
    if [[ -n "$last_wallpaper" ]]; then
        for i in "${!files[@]}"; do
            if [[ "${files[$i]}" == "$last_wallpaper" ]]; then
                current_index=$i
                break
            fi
        done
    fi

    # Rotate the array cleanly so the current wallpaper is always at index 0 (the start)
    len=${#files[@]}
    ordered_files=()
    for ((i = 0; i < len; i++)); do
        idx=$(( (current_index + i) % len ))
        ordered_files+=("${files[$idx]}")
    done

    # Build menu input
    menu_input=""
    for f in "${ordered_files[@]}"; do
        menu_input+="$(basename "$f")\0icon\x1f$f\n"
    done

    # Open rofi starting on the current wallpaper (index 0), allowing dynamic cycling both ways
    selected_name=$(printf "$menu_input" | rofi -dmenu -theme "$THEME_FILE" -hide-scrollbar -no-lazy-grab -selected-row 0)

    if [ -z "$selected_name" ]; then
        break
    fi

    feh --bg-fill "$WALLPAPER_DIR/$selected_name"
    echo "$WALLPAPER_DIR/$selected_name" > "$CACHE_FILE"
done