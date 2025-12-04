#!/bin/bash

# Arch Linux Dotfiles Installer
# Compatible with Arch Linux and Arch-based distributions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}➜${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_step() {
    echo -e "\n${CYAN}==>${NC} $1"
}

# Progress bar function
show_progress() {
    local current=$1
    local total=$2
    local message=$3
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    
    printf "\r${BLUE}[${NC}"
    printf "%${completed}s" | tr ' ' '='
    printf "%$((width - completed))s" | tr ' ' ' '
    printf "${BLUE}]${NC} ${percentage}%% - ${message}"
    
    if [ $current -eq $total ]; then
        echo ""
    fi
}

# Check if running on Arch Linux
check_arch() {
    if [ ! -f /etc/arch-release ]; then
        print_error "This script is designed for Arch Linux."
        print_info "For other distributions, please use the appropriate install script."
        exit 1
    fi
    print_success "Arch Linux system detected"
}

# Backup existing dotfiles
backup_dotfiles() {
    print_step "Backing up existing dotfiles..."
    local backup_dir="$HOME/.dotfiles_backup"
    
    if [ ! -d "$backup_dir" ]; then
        mkdir -p "$backup_dir"
    fi
    
    local files=(".zshrc" ".gitconfig" ".aliases" ".vimrc" ".p10k.zsh")
    local backed_up=0
    
    for file in "${files[@]}"; do
        if [ -f "$HOME/$file" ] || [ -L "$HOME/$file" ]; then
            mv "$HOME/$file" "$backup_dir/" 2>/dev/null && backed_up=$((backed_up + 1))
        fi
    done
    
    if [ $backed_up -gt 0 ]; then
        print_success "Backed up $backed_up file(s) to $backup_dir"
    else
        print_info "No existing dotfiles found to backup"
    fi
}

# Install required packages
install_packages() {
    print_step "Installing required packages..."
    
    # Update package database
    print_info "Updating package database..."
    sudo pacman -Sy --noconfirm
    
    # Install packages
    local packages=(
        "git"
        "curl"
        "wget"
        "zsh"
        "vim"
        "base-devel"
    )
    
    print_info "Installing packages: ${packages[@]}"
    sudo pacman -S --noconfirm "${packages[@]}"
    print_success "Packages installed successfully"
}

# Link dotfiles
link_dotfiles() {
    print_step "Linking dotfiles..."
    
    local dotfiles_dir="$HOME/.dotfiles"
    local files=("gitconfig" "aliases" "vimrc" "zshrc" "p10k.zsh")
    local total=${#files[@]}
    local current=0
    
    for file in "${files[@]}"; do
        src="$dotfiles_dir/$file"
        dest="$HOME/.$file"
        
        if [ ! -e "$src" ]; then
            print_warning "Source file not found: $src"
            continue
        fi
        
        if [ -e "$dest" ] && [ ! -L "$dest" ]; then
            print_warning "File exists (not a symlink): $dest"
            continue
        fi
        
        rm -f "$dest"
        ln -s "$src" "$dest"
        print_success "Linked $file"
        
        current=$((current + 1))
        show_progress $current $total "Linking dotfiles"
    done
}

# Install Oh-My-Zsh if missing
install_oh_my_zsh() {
    print_step "Installing Oh-My-Zsh..."
    
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_warning "Oh-My-Zsh is already installed"
    else
        print_info "Installing Oh-My-Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "Oh-My-Zsh installed successfully"
    fi
}

# Install Powerlevel10k theme
install_theme() {
    print_step "Installing Powerlevel10k theme..."
    
    local theme_dir="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    
    if [ -d "$theme_dir" ]; then
        print_warning "Powerlevel10k theme is already installed"
    else
        print_info "Cloning Powerlevel10k repository..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$theme_dir"
        print_success "Powerlevel10k theme installed successfully"
    fi
}

# Install Zsh plugins
install_plugins() {
    print_step "Installing Zsh plugins..."
    
    local plugins_dir="$HOME/.oh-my-zsh/custom/plugins"
    mkdir -p "$plugins_dir"
    
    # Array of plugins to install
    local plugins=(
        "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions"
        "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting"
        "zsh-completions:https://github.com/zsh-users/zsh-completions"
        "zsh-history-substring-search:https://github.com/zsh-users/zsh-history-substring-search"
    )
    
    for plugin_entry in "${plugins[@]}"; do
        IFS=':' read -r plugin_name plugin_url <<< "$plugin_entry"
        local plugin_path="$plugins_dir/$plugin_name"
        
        if [ -d "$plugin_path" ]; then
            print_warning "$plugin_name is already installed"
        else
            print_info "Installing $plugin_name..."
            git clone "$plugin_url" "$plugin_path"
            print_success "$plugin_name installed"
        fi
    done
}

# Install OpenJDK if missing
install_java() {
    print_step "Checking Java installation..."
    
    if command -v java &>/dev/null; then
        local java_version=$(java -version 2>&1 | head -n 1)
        print_success "Java is already installed: $java_version"
    else
        print_info "Installing OpenJDK 17..."
        sudo pacman -S --noconfirm jdk17-openjdk
        
        # Set JAVA_HOME in .zshrc if not already set
        if ! grep -q "JAVA_HOME" "$HOME/.zshrc"; then
            local java_path=$(readlink -f $(which java) | sed "s:bin/java::")
            echo "export JAVA_HOME=$java_path" >> "$HOME/.zshrc"
            echo 'export PATH=$JAVA_HOME/bin:$PATH' >> "$HOME/.zshrc"
            print_success "JAVA_HOME configured and added to .zshrc"
        fi
    fi
}

# Set Zsh as default shell
set_default_shell() {
    print_step "Setting Zsh as default shell..."
    
    local current_shell=$(echo $SHELL)
    local zsh_path=$(which zsh)
    
    if [ "$current_shell" = "$zsh_path" ]; then
        print_success "Zsh is already the default shell"
    else
        print_info "Changing default shell to Zsh..."
        chsh -s "$zsh_path"
        print_success "Default shell changed to Zsh"
    fi
}

# Install nerd fonts recommendation
install_fonts() {
    print_step "Font setup for Powerlevel10k..."
    
    if command -v yay &>/dev/null || command -v paru &>/dev/null; then
        local aur_helper=$(command -v yay || command -v paru)
        print_info "AUR helper found: $aur_helper"
        print_info "Consider installing nerd fonts via: $aur_helper -S noto-fonts-nerd"
        print_info "Or manually from: https://www.nerdfonts.com/font-downloads"
    else
        print_warning "Consider installing nerd fonts from AUR:"
        print_info "Install yay or paru first, then: yay -S noto-fonts-nerd"
    fi
}

# Display final summary
print_summary() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║          Arch Linux Dotfiles Installation Complete!       ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}✓${NC} System packages installed"
    echo -e "${GREEN}✓${NC} Dotfiles linked"
    echo -e "${GREEN}✓${NC} Oh-My-Zsh installed"
    echo -e "${GREEN}✓${NC} Powerlevel10k theme configured"
    echo -e "${GREEN}✓${NC} Zsh plugins installed"
    echo -e "${GREEN}✓${NC} Java environment configured"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Close and reopen your terminal to apply changes"
    echo "2. Run 'p10k configure' to customize your terminal appearance"
    echo "3. Install a Nerd Font for best experience (Noto, Meslo, or FiraCode)"
    echo ""
    echo -e "${BLUE}Backup location:${NC} $HOME/.dotfiles_backup"
    echo ""
}

# Main execution
main() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                           ║${NC}"
    echo -e "${CYAN}║${NC}        ${MAGENTA}Arch Linux Dotfiles Installation Script${NC}         ${CYAN}║${NC}"
    echo -e "${CYAN}║                                                           ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    check_arch
    backup_dotfiles
    install_packages
    install_oh_my_zsh
    install_theme
    install_plugins
    link_dotfiles
    install_java
    install_fonts
    set_default_shell
    print_summary
}

main
