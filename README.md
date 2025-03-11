# My Dotfiles

This repository contains my personal dotfiles for Arch Linux.

## Contents

* `.fonts`: Custom fonts.
* `.icons`: Custom icons.
* `.themes`: Custom themes.
* `config/`: Configuration files for various applications.
    * `auto-cpufreq`
    * `dunst`
    * `flameshot`
    * `gtk-2.0`
    * `gtk-3.0`
    * `i3`
    * `kitty`
    * `neofetch`
    * `nvim`
    * `picom`
    * `polybar`
    * `rofi`
    * `wallpaper`
    * `xfce4`
    * `user-dirs.dirs`
* `zsh/`: Zsh configuration files.
    * `.alias`
    * `.rules`
    * `.zprofile`
    * `.zsh_warp_completion`
    * `.zshrc`
* `30-touchpad.conf`: Touchpad configuration.
* `.xinitrc`: X11 startup script.
* `setup.sh`: Script to automate setup.
* `README.md`: This file.

## Prerequisites

* Arch Linux
* `i3-gaps`
* `polybar`
* `dunst`
* `rofi`
* `flameshot`
* `kitty`
* `neofetch`
* `neovim`
* `picom`
* `zsh`
* `auto-cpufreq`
* `xorg-server`
* `xorg-xinit`
* `base-devel`
* `git`
* GTK themes
* Yay (AUR helper)

## Installation

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/mdsufiyan01/dotfiles/tree/main ~/.dotfiles
    ```

2.  **Run the setup script:**

    ```bash
    cd ~/.dotfiles
    chmod +x setup.sh
    ./setup.sh
    ```
3. **DONE**