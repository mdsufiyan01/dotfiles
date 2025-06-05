#!/bin/bash

# Configuration and error handling
set -euo pipefail # Exit on error, unset variables, or failed pipeline

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # Script's directory
CONFIG_DIR="$HOME/.config"

# Files and directories to symlink
config_files=(
    "auto-cpufreq" "dunst" "flameshot" "gtk-2.0" "gtk-3.0" "i3" "kitty" "dmenu"
    "neofetch" "nvim" "picom" "polybar" "rofi" "wallpaper" "xfce4" "user-dirs.dirs"
)
zsh_files=(
    "zsh/.alias" "zsh/.rules" "zsh/.zprofile" "zsh/.zsh_warp_completion" "zsh/.zshrc"
)
home_files=(
    ".xinitrc" ".fonts" ".icons" ".themes"
)

# --- Helper Functions ---

log_info() { echo "--- INFO: $1"; }
log_success() { echo "--- SUCCESS: $1"; }
log_warn() { echo "--- WARNING: $1"; }
log_error() { echo "--- ERROR: $1" >&2; exit 1; }

command_exists() { command -v "$1" &> /dev/null; }

# Ask for yes/no. $1: prompt, $2: default (true for Y/n, false for y/N)
ask_yes_no() {
    local prompt_message="$1" choice
    if "${2:-true}"; then read -rp "$prompt_message (Y/n): " choice; choice=${choice:-y};
    else read -rp "$prompt_message (y/N): " choice; choice=${choice:-n}; fi
    [[ "$choice" =~ ^[yY]$ ]]
}

# --- Core Functions ---

install_yay() {
    log_info "Checking for yay."
    command_exists yay && { log_success "yay is installed."; return 0; }

    log_info "Installing yay prerequisites."
    sudo pacman -S --needed base-devel git || log_error "Failed base-devel/git."

    local yay_dir=$(mktemp -d)
    log_info "Cloning yay."
    git clone https://aur.archlinux.org/yay.git "$yay_dir" || log_error "Failed to clone yay."

    log_info "Building yay."
    (cd "$yay_dir" && makepkg -si --noconfirm) || log_error "Failed to install yay."
    rm -rf "$yay_dir"
    log_success "yay installed."
}

install_prerequisites() {
    log_info "Installing core apps."
    local core_packages=(
        i3-gaps polybar dunst rofi flameshot kitty neofetch neovim picom zsh
        auto-cpufreq gtk2 gtk3 wget xorg-server xorg-xinit ttf-dejavu
    )
    yay -S --needed "${core_packages[@]}" || log_error "Failed to install core apps."
    log_success "Core apps installed."
}

install_optional_utilities() {
    log_info "Offering optional utilities."
    local all_optional_packages=(
        "ttf-jetbrains-mono-nerd" "ttf-fantasque-sans-mono" "pulseaudio" "pulseaudio-alsa"
        "pamixer" "nemo" "tldr" "exa" "bat" "feh" "copyq" "brightnessctl" "thorium-browser-bin"
    )
    if ask_yes_no "Install *all* recommended optional utilities/fonts (incl. Thorium Browser)? (May take a while)" false; then
        log_info "Installing selected optional packages."
        yay -S --needed "${all_optional_packages[@]}" || log_warn "Some optional packages failed."
        log_success "Optional packages installation completed."
    else
        log_info "Skipping optional utilities."
    fi
}

# Create symlinks. $1: src_subdir (relative to DOTFILES_DIR), $2: dest_dir (abs path), $3: array_name
create_symlinks() {
    local src_subdir="$1" dest_dir="$2"
    local -n files_array="$3" # Nameref to access array by name

    log_info "Creating symlinks from $src_subdir to $dest_dir."
    for file in "${files_array[@]}"; do
        local source_path="$DOTFILES_DIR/$src_subdir/$file" dest_path="$dest_dir/$file"
        local dest_parent_dir="$(dirname "$dest_path")"

        [[ ! -e "$source_path" && ! -L "$source_path" ]] && { log_warn "Source missing: $source_path. Skipping."; continue; }
        mkdir -p "$dest_parent_dir" || log_error "Failed to create dir: $dest_parent_dir"

        if [ -e "$dest_path" ] || [ -L "$dest_path" ]; then
            if [[ -L "$dest_path" && "$(readlink -f "$dest_path")" == "$(readlink -f "$source_path")" ]]; then
                log_info "Symlink correct: $dest_path. Skipping."
                continue
            elif [[ -d "$dest_path" && ! -L "$dest_path" ]]; then # Real directory found
                log_warn "Existing directory: $dest_path. Removing to symlink."
                rm -rf "$dest_path" || log_error "Failed to remove dir: $dest_path"
            else # Existing file or wrong symlink
                log_warn "Existing file/incorrect symlink: $dest_path. Removing."
                rm -rf "$dest_path" || log_error "Failed to remove item: $dest_path"
            fi
        fi
        ln -sf "$source_path" "$dest_path" || log_error "Failed to symlink: $source_path -> $dest_path"
        log_info "Symlinked: $source_path -> $dest_path"
    done
    log_success "Symlinking from $src_subdir to $dest_dir completed."
}

copy_touchpad_config() {
    local src="$DOTFILES_DIR/30-touchpad.conf" dest="/etc/X11/xorg.conf.d/30-touchpad.conf"
    [[ ! -f "$src" ]] && { log_warn "Touchpad config not found: $src. Skipping."; return 0; }

    log_info "Copying 30-touchpad.conf."
    sudo mkdir -p "$(dirname "$dest")" || log_error "Failed to create dir for touchpad config."

    if [ -f "$dest" ]; then
        read -rp "30-touchpad.conf exists in /etc. Overwrite? (Y/n/b for backup): " choice
        case "${choice:-y}" in
            [nN]*) log_warn "Skipping touchpad config."; return 0;;
            [bB]*) sudo cp "$dest" "${dest}.bak" || log_error "Failed to backup touchpad config.";;
        esac
    fi
    sudo cp "$src" "$dest" || log_error "Failed to copy touchpad config."
    log_success "Copied 30-touchpad.conf."
}

install_oh_my_zsh_plugins() {
    log_info "Oh My Zsh installation."
    if ! ask_yes_no "Install Oh My Zsh and plugins?" true; then log_info "OMZ cancelled."; return 0; fi

    log_info "Installing Oh My Zsh."
    if [ -d "$HOME/.oh-my-zsh" ]; then log_warn "Oh My Zsh already installed. Skipping base.";
    else command_exists wget && sh -c "$(wget -O - https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || log_error "OMZ failed."; fi
    log_success "Oh My Zsh installed/skipped."

    log_info "Installing zsh-syntax-highlighting."
    local synth_highlight_dir="$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
    [[ -d "$synth_highlight_dir" ]] || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$synth_highlight_dir" || log_error "Failed to clone zsh-syntax-highlighting."
    log_warn "zsh-syntax-highlighting already exists. Skipping clone."

    log_info "Installing zsh-autosuggestions."
    local autosuggestions_dir="$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
    [[ -d "$autosuggestions_dir" ]] || git clone https://github.com/zsh-users/zsh-autosuggestions.git "$autosuggestions_dir" || log_error "Failed to clone zsh-autosuggestions."
    log_warn "zsh-autosuggestions already exists. Skipping clone."
    log_success "Zsh plugins installed/skipped."

    log_info "Skipping automatic .zshrc plugin config. Ensure your .zshrc includes them."

    read -rp "Change default shell to zsh? (Y/n): " choice_shell
    case "${choice_shell:-y}" in
        [yY]*)
            [ "$(basename "$SHELL")" = "zsh" ] && log_success "Shell already zsh." && return 0
            log_info "Changing shell to zsh (password may be prompted)."
            chsh -s "$(command -v zsh)" || log_error "Failed to change shell."
            log_info "Log out/in or open new terminal for changes."
            ;;
        [nN]*) log_info "Change shell manually later with 'chsh -s $(command -v zsh)'.";;
        *) log_warn "Invalid input. Shell not changed.";;
    esac
    log_success "Oh My Zsh setup complete!"
}

# --- Main Execution ---
main() {
    log_info "Starting Dotfiles Setup."

    install_yay
    install_prerequisites
    install_optional_utilities # Single prompt for all optional packages

    create_symlinks "config" "$CONFIG_DIR" config_files
    create_symlinks "zsh" "$HOME" zsh_files
    create_symlinks "" "$HOME" home_files

    copy_touchpad_config
    install_oh_my_zsh_plugins # Run at the end

    log_success "Dotfiles setup completed! Please reboot or log out/in for all changes to take effect."
}

main "$@"