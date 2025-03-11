#!/bin/bash

# Dotfiles Directory
DOTFILES_DIR="$HOME/.dotfiles"
CONFIG_DIR="$HOME/.config"

# Array of config files and directories to symlink
config_files=(
    "auto-cpufreq"
    "dunst"
    "flameshot"
    "gtk-2.0"
    "gtk-3.0"
    "i3"
    "kitty"
    "neofetch"
    "nvim"
    "picom"
    "polybar"
    "rofi"
    "wallpaper"
    "xfce4"
    "user-dirs.dirs"
)

# Array of zsh files to symlink to home
zsh_files=(
    "zsh/.alias"
    "zsh/.rules"
    "zsh/.zprofile"
    "zsh/.zsh_warp_completion"
    "zsh/.zshrc"
)

# Array of home directory files to symlink
home_files=(
    ".xinitrc"
    ".fonts"
    ".icons"
    ".themes"
)

# Function to install yay and its prerequisites
install_yay() {
    if command -v yay &> /dev/null; then
        echo "yay is already installed."
        return
    fi

    echo "Installing yay and its prerequisites..."

    sudo pacman -S --needed base-devel git
    if [ $? -ne 0 ]; then
        echo "Error installing base-devel and git. Exiting."
        exit 1
    fi
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    if [ $? -ne 0 ]; then
        echo "Error installing yay. Exiting."
        exit 1
    fi
    cd ..
    rm -rf yay

    echo "yay installed successfully."
}

# Function to install prerequisite applications
install_prerequisites() {
    echo "Installing prerequisite applications..."

    yay -S --needed \
        i3-gaps \
        polybar \
        dunst \
        rofi \
        flameshot \
        kitty \
        neofetch \
        neovim \
        picom \
        zsh \
        auto-cpufreq \
        gtk2 \
        gtk3 \
        xorg-server \
        xorg-xinit \
        ttf-dejavu \
        ttf-font-awesome
    if [ $? -ne 0 ]; then
        echo "Error installing prerequisite applications. Exiting."
        exit 1
    fi

    echo "Prerequisite applications installed."
}

# Function to create symlinks for config files
create_config_symlinks() {
    for file in "${config_files[@]}"; do
        # Create destination directory if it doesn't exist
        mkdir -p "$CONFIG_DIR/$(dirname "$file")"

        # Check if the destination already exists
        if [ -e "$CONFIG_DIR/$file" ]; then
            # Remove existing file/directory if it's not a symlink
            if [[ ! -L "$CONFIG_DIR/$file" ]]; then
                echo "Removing existing file/directory: $CONFIG_DIR/$file"
                rm -rf "$CONFIG_DIR/$file"
            fi
        fi

        # Create the symlink
        ln -sf "$DOTFILES_DIR/config/$file" "$CONFIG_DIR/$file"
        echo "Symlinked: $CONFIG_DIR/$file"
    done
}

# Function to create symlinks for zsh files to home directory
create_zsh_symlinks() {
    for file in "${zsh_files[@]}"; do
        # Check if the destination already exists
        if [ -e "$HOME/$(basename "$file")" ]; then
            # Remove existing file/directory if it's not a symlink
            if [[ ! -L "$HOME/$(basename "$file")" ]]; then
                echo "Removing existing file/directory: $HOME/$(basename "$file")"
                rm -rf "$HOME/$(basename "$file")"
            fi
        fi
        ln -sf "$DOTFILES_DIR/$file" "$HOME/$(basename "$file")"
        echo "Symlinked: $HOME/$(basename "$file")"
    done
}

# Function to create symlinks for home files
create_home_symlinks() {
    for file in "${home_files[@]}"; do
        # Check if the destination already exists
        if [ -e "$HOME/$file" ]; then
            # Remove existing file/directory if it's not a symlink
            if [[ ! -L "$HOME/$file" ]]; then
                echo "Removing existing file/directory: $HOME/$file"
                rm -rf "$HOME/$file"
            fi
        fi
        ln -sf "$DOTFILES_DIR/$file" "$HOME/$file"
        echo "Symlinked: $HOME/$file"
    done
}

# Handle the touchpad config separately
copy_touchpad_config() {
    if [ -f "$DOTFILES_DIR/30-touchpad.conf" ]; then
        sudo mkdir -p /etc/X11/xorg.conf.d/
        sudo cp "$DOTFILES_DIR/30-touchpad.conf" /etc/X11/xorg.conf.d/30-touchpad.conf
        echo "Copied 30-touchpad.conf to /etc/X11/xorg.conf.d/"
    fi
}

# Oh My Zsh and plugin installation
install_oh_my_zsh_plugins() {
    read -p "Do you want to install Oh My Zsh? (y/n): " choice

    case "$choice" in
        [yY]*)
            echo "Installing Oh My Zsh..."
            sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

            # Check if the installation was successful (simplistic check)
            if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
                echo "Oh My Zsh installation failed."
                return 1
            fi

            echo "Oh My Zsh installed successfully!"

            # Install zsh-syntax-highlighting
            echo "Installing zsh-syntax-highlighting..."
            git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting"

            # Install zsh-autosuggestions
            echo "Installing zsh-autosuggestions..."
            git clone https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.oh-my-zsh/plugins/zsh-autosuggestions"

            echo "Plugins installed. Please manually add them to your .zshrc."

            # Prompt to change the default shell to zsh.
            read -p "Do you want to change your default shell to zsh? (y/n): " choice_shell
            case "$choice_shell" in
                [yY]*)
                    chsh -s $(which zsh)
                    echo "Please log out and log back in or open a new terminal for the changes to take effect."
                    ;;
                [nN]*)
                    echo "You can manually change your shell using 'chsh -s $(which zsh)' later."
                    ;;
                *)
                    echo "Invalid input. Shell not changed."
                    ;;
            esac

            echo "Oh My Zsh installation complete!"
            return 0
            ;;
        [nN]*)
            echo "Oh My Zsh installation cancelled."
            return 0
            ;;
        *)
            echo "Invalid input."
            return 1
            ;;
    esac
}

# Main execution
install_yay
install_prerequisites
create_config_symlinks
create_zsh_symlinks
create_home_symlinks
copy_touchpad_config
install_oh_my_zsh_plugins

echo "Dotfiles setup completed successfully!"