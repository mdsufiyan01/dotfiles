# Arch Linux .dotfiles

This repository contains my personal dotfiles, configured for an Arch Linux environment. These configurations are designed to create a customized and efficient desktop experience.

## Contents

* **`config/`:**
    * `auto-cpufreq/`: Configuration for automatic CPU frequency scaling.
    * `dunst/`: Dunst notification daemon configuration.
    * `flameshot/`: Flameshot screenshot tool configuration.
    * `gtk-2.0/`: GTK 2.0 theme and appearance settings.
    * `gtk-3.0/`: GTK 3.0 theme and appearance settings.
    * `i3/`: i3 window manager configuration.
    * `kitty/`: Kitty terminal emulator configuration.
    * `neofetch/`: Neofetch system information configuration.
    * `nvim/`: Neovim editor configuration.
    * `picom/`: Picom compositor configuration.
    * `polybar/`: Polybar status bar configuration.
    * `rofi/`: Rofi application launcher configuration.
    * `wallpaper/`: Wallpaper files and related configuration.
    * `xfce4/`: XFCE4 related configuration files.
    * `user-dirs.dirs`: configuration for user directories.
* **`zsh/`:**
    * `.alias`: Zsh aliases.
    * `.rules`: Custom zsh rules.
    * `.zprofile`: Zsh profile configuration.
    * `.zsh_warp_completion`: Zsh warp completion configuration.
    * `.zshrc`: Zsh shell configuration.
* **`30-touchpad.conf`:** Xorg touchpad configuration.
* **`README.md`:** This file.

## Prerequisites

Ensure the following packages (and any dependencies) are installed on your Arch Linux system:

* `i3-gaps` (or `i3`)
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
* GTK themes and related packages.
* Xorg and related packages.

## Installation

1.  **Clone the repository:**

    ```bash
    git clone git@github.com:your_username/dotfiles.git ~/.dotfiles
    ```

    (Replace `your_username` with your GitHub username.)

2.  **Create symbolic links (symlinks):**

    Apply configurations by creating symbolic links from the repository to their respective locations.

    **Example (for `.zshrc`):**

    ```bash
    ln -sf ~/.dotfiles/zsh/.zshrc ~/.zshrc
    ```

    Repeat for each desired file and directory.

3.  **Automated symlinking script:**

    A script is provided to automate the symlinking process. To use it:

    1.  Ensure the `symlink.sh` script is in your `.dotfiles` directory.
    2.  Make it executable: `chmod +x symlink.sh`
    3.  Run the script: `./symlink.sh`

    The `30-touchpad.conf` file will be placed in `/etc/X11/xorg.conf.d/` with `sudo` permissions.

