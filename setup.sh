#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
NC='\033[0m' # No Color

# Dotfiles Directory
DOTFILES_DIR="$HOME/.dotfiles"
CONFIG_DIR="<span class="math-inline">HOME/\.config"
\# Array of config files and directories to symlink
config\_files\=\(
"auto\-cpufreq"
"dunst"
"flameshot"
"gtk\-2\.0"
"gtk\-3\.0"
"i3"
"kitty"
"neofetch"
"nvim"
"picom"
"polybar"
"rofi"
"wallpaper"
"xfce4"
"user\-dirs\.dirs"
\)
\# Array of zsh files to symlink to home
zsh\_files\=\(
"zsh/\.alias"
"zsh/\.rules"
"zsh/\.zprofile"
"zsh/\.zsh\_warp\_completion"
"zsh/\.zshrc"
\)
\# Array of home directory files to symlink
home\_files\=\(
"\.xinitrc"
"\.fonts"
"\.icons"
"\.themes"
\)
\# Function to install yay and its prerequisites
install\_yay\(\) \{
if command \-v yay &\> /dev/null; then
echo "</span>{GREEN}yay is already installed.<span class="math-inline">\{NC\}"
return
fi
echo "</span>{YELLOW}Installing yay and its prerequisites...${NC}"

    sudo pacman -S --needed base-devel git
    if [ <span class="math-inline">? \-ne 0 \]; then
echo "</span>{RED}Error installing base-devel and git. Exiting.${NC}"
        exit 1
    fi
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    if [ <span class="math-inline">? \-ne 0 \]; then
echo "</span>{RED}Error installing yay. Exiting.<span class="math-inline">\{NC\}"
exit 1
fi
cd \.\.
rm \-rf yay
echo "</span>{GREEN}yay installed successfully.<span class="math-inline">\{NC\}"
\}
\# Function to install prerequisite applications
install\_prerequisites\(\) \{
echo "</span>{YELLOW}Installing prerequisite applications...${NC}"

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
        wget \
        xorg-server \
        xorg-xinit \
        ttf-dejavu \
        ttf-font-awesome
    if [ <span class="math-inline">? \-ne 0 \]; then
echo "</span>{RED}Error installing prerequisite applications. Exiting.<span class="math-inline">\{NC\}"
exit 1
fi
echo "</span>{GREEN}Prerequisite applications installed.<span class="math-inline">\{NC\}"
\}
\# Function to create symlinks for config files
create\_config\_symlinks\(\) \{
for file in "</span>{config_files[@]}"; do
        # Create destination directory if it doesn't exist
        mkdir -p "<span class="math-inline">CONFIG\_DIR/</span>(dirname "$file")"

        # Check if the destination already exists
        if [ -e "$CONFIG_DIR/$file" ]; then
            # Remove existing file/directory if it's not a symlink
            if [[ ! -L "$CONFIG_DIR/<span class="math-inline">file" \]\]; then
echo "</span>{YELLOW}Removing existing file/directory: $CONFIG_DIR/<span class="math-inline">file</span>{NC}"
                rm -rf "$CONFIG_DIR/$file"
            fi
        fi

        # Create the symlink
        ln -sf "$DOTFILES_DIR/config/$file" "$CONFIG_DIR/<span class="math-inline">file"
echo "</span>{GREEN}Symlinked: $CONFIG_DIR/<span class="math-inline">file</span>{NC}"
    done
}

# Function to create symlinks for zsh files to home directory
create_zsh_symlinks() {
    for file in "${zsh_files[@]}"; do
        # Check if the destination already exists
        if [ -e "<span class="math-inline">HOME/</span>(basename "$file")" ]; then
            # Remove existing file/directory if it's not a symlink
            if [[ ! -L "<span class="math-inline">HOME/</span>(basename "<span class="math-inline">file"\)" \]\]; then
echo "</span>{YELLOW}Removing existing file/directory: <span class="math-inline">HOME/</span>(basename "<span class="math-inline">file"\)</span>{NC}"
                rm -rf "<span class="math-inline">HOME/</span>(basename "$file")"
            fi
        fi
        ln -sf "$DOTFILES_DIR/$file" "<span class="math-inline">HOME/</span>(basename "<span class="math-inline">file"\)"
echo "</span>{GREEN}Symlinked: <span class="math-inline">HOME/</span>(basename "<span class="math-inline">file"\)</span>{NC}"
    done
}

# Function to create symlinks for home files
create_home_symlinks() {
    for file in "${home_files[@]}"; do
        # Check if the destination already exists
        if [ -e "$HOME/$file" ]; then
            # Remove existing file/directory if it's not a symlink
            if [[ ! -L "$HOME/<span class="math-inline">file" \]\]; then
echo "</span>{YELLOW}Removing existing file/directory: $HOME/<span class="math-inline">file</span>{NC}"
                rm -rf "$HOME/$file"
            fi
        fi
        ln -sf "$DOTFILES_DIR/$file" "$HOME/<span class="math-inline">file"
echo "</span>{GREEN}Symlinked: $HOME/<span class="math-inline">file</span>{NC}"
    done
}

# Handle the touchpad config separately
copy_touchpad_config() {
    if [ -f "$DOTFILES_DIR/30-touchpad.conf" ]; then
        sudo mkdir -p /etc/X11/xorg.conf.d/
        sudo cp "<span class="math-inline">DOTFILES\_DIR/30\-touchpad\.conf" /etc/X11/xorg\.conf\.d/30\-touchpad\.conf
echo "</span>{GREEN}Copied 30-touchpad.conf to /etc/X11/xorg.conf.d/<span class="math-inline">\{NC\}"
fi
\}
\# Oh My Zsh and plugin installation
install\_oh\_my\_zsh\_plugins\(\) \{
read \-rp "</span>{CYAN}Do you want to install Oh My Zsh? (<span class="math-inline">\{GREEN\}Y</span>{CYAN}/n): <span class="math-inline">\{NC\}" choice
choice\=</span>{choice:-y} # Default to 'y' if nothing is entered

    case "<span class="math-inline">choice" in
\[yY\]\*\)
echo "</span>{YELLOW}Installing Oh My Zsh...<span class="math-inline">\{NC\}"
sh \-c "</span>(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

            # Check if the installation was successful (simplistic check)
            if [[ ! -d "<span class="math-inline">HOME/\.oh\-my\-zsh" \]\]; then
echo "</span>{RED}Oh My Zsh installation failed.<span class="math-inline">\{NC\}"
return 1
fi
echo "</span>{GREEN}Oh My Zsh installed successfully!<span class="math-inline">\{NC\}"
\# Install zsh\-syntax\-highlighting
echo "</span>{YELLOW}Installing zsh-syntax-highlighting...${NC}"
            git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "<span class="math-inline">HOME/\.oh\-my\-zsh/plugins/zsh\-syntax\-highlighting"
\# Install zsh\-autosuggestions
echo "</span>{YELLOW}Installing zsh-autosuggestions...${NC}"
            git clone https://github.com/zsh-users/zsh-autosuggestions.git "<span class="math-inline">HOME/\.oh\-my\-zsh/plugins/zsh\-autosuggestions"
echo "</span>{GREEN}Plugins installed. Please manually add them to your .zshrc.<span class="math-inline">\{NC\}"
\# Prompt to change the default shell to zsh\.
read \-rp "</span>{CYAN}Do you want to change your default shell to zsh? (<span class="math-inline">\{GREEN\}Y</span>{CYAN}/n): <span class="math-inline">\{NC\}" choice\_shell
choice\_shell\=</span>{choice_shell:-y} # Default to y if nothing is entered.
            case "$choice_shell" in
                [yY]*)
                    chsh -s <span class="math-inline">\(which zsh\)
echo "</span>{GREEN}Please log out and log back in or open a new terminal for the changes to take effect.<span class="math-inline">\{NC\}"
;;
\[nN\]\*\)
echo "</span>{YELLOW}You can manually change your shell using 'chsh -s <span class="math-inline">\(which zsh\)' later\.</span>{NC}"
                    ;;
                *)
                    echo "<span class="math-inline">\{RED\}Invalid input\. Shell not changed\.</span>{NC}"
                    ;;
            esac

            echo "<span class="math-inline">\{GREEN\}Oh My Zsh installation complete\!</span>{NC}"
            return 0