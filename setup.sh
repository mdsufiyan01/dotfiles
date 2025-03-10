#!/bin/bash

# Dotfiles Directory
DOTFILES_DIR="$HOME/.dotfiles"

# Array of files and directories to symlink
files=(
    "zsh/.alias"
    "zsh/.rules"
    "zsh/.zprofile"
    "zsh/.zsh_warp_completion"
    "zsh/.zshrc"
    "config/user-dirs.dirs"
    "config/auto-cpufreq"
    "config/dunst"
    "config/flameshot"
    "config/gtk-2.0"
    "config/gtk-3.0"
    "config/i3"
    "config/kitty"
    "config/neofetch"
    "config/nvim"
    "config/picom"
    "config/polybar"
    "config/rofi"
    "config/wallpaper"
    "config/xfce4"
)

# Function to create symlinks
create_symlinks() {
    for file in "${files[@]}"; do
        # Create destination directory if it doesn't exist
        mkdir -p "$(dirname "$HOME/${file#*/}")"

        # Check if the destination already exists
        if [ -e "$HOME/${file#*/}" ]; then
            # Remove existing file/directory if it's not a symlink
            if [[ ! -L "$HOME/${file#*/}" ]]; then
                echo "Removing existing file/directory: $HOME/${file#*/}"
                rm -rf "$HOME/${file#*/}"
            fi
        fi

        # Create the symlink
        ln -sf "$DOTFILES_DIR/${file}" "$HOME/${file#*/}"
        echo "Symlinked: $file"
    done

    # Handle the touchpad config separately
    if [ -f "$DOTFILES_DIR/30-touchpad.conf" ]; then
        sudo mkdir -p /etc/X11/xorg.conf.d/
        sudo ln -sf "$DOTFILES_DIR/30-touchpad.conf" /etc/X11/xorg.conf.d/30-touchpad.conf
        echo "Symlinked 30-touchpad.conf to /etc/X11/xorg.conf.d/"
    fi
}

# Main execution
create_symlinks

echo "Dotfiles symlinked successfully!"