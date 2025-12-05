#!/bin/bash

# Arch Linux Zsh Installation Script
# Installs Zsh, Oh My Zsh, Powerlevel10k, and essential plugins

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Helper functions
print_banner() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                           ║${NC}"
    echo -e "${CYAN}║${NC}     ${MAGENTA}Arch Linux Zsh + Oh My Zsh Installation${NC}         ${CYAN}║${NC}"
    echo -e "${CYAN}║                                                           ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo -e "\n${BLUE}==>${NC} ${1}"
}

print_success() {
    echo -e "${GREEN}✓${NC} ${1}"
}

print_error() {
    echo -e "${RED}✗${NC} ${1}"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} ${1}"
}

print_info() {
    echo -e "${CYAN}ℹ${NC} ${1}"
}

# Check if running on Arch Linux
check_system() {
    print_step "Checking system compatibility..."
    
    if [ ! -f /etc/arch-release ]; then
        print_error "This script is designed for Arch Linux"
        print_info "Detected: $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2)"
        exit 1
    fi
    
    print_success "Arch Linux detected"
}

# Check if running as root
check_root() {
    if [ "$EUID" -eq 0 ]; then
        print_error "Please do not run this script as root"
        print_info "The script will ask for sudo password when needed"
        exit 1
    fi
}

# Install Zsh and dependencies
install_zsh() {
    print_step "Installing Zsh and dependencies..."
    
    # Check if zsh is already installed
    if command -v zsh &>/dev/null; then
        local zsh_version=$(zsh --version | cut -d' ' -f2)
        print_success "Zsh $zsh_version is already installed"
    else
        print_info "Installing zsh..."
        sudo pacman -Sy --noconfirm zsh
        print_success "Zsh installed successfully"
    fi
    
    # Install additional dependencies
    print_info "Installing additional dependencies..."
    sudo pacman -Sy --noconfirm git curl wget base-devel
    print_success "Dependencies installed"
}

# Install Oh My Zsh
install_oh_my_zsh() {
    print_step "Installing Oh My Zsh..."
    
    local zsh_dir="$HOME/.oh-my-zsh"
    
    if [ -d "$zsh_dir" ]; then
        print_warning "Oh My Zsh is already installed at $zsh_dir"
        read -p "Do you want to reinstall? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Skipping Oh My Zsh installation"
            return
        fi
        rm -rf "$zsh_dir"
    fi
    
    print_info "Downloading Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    if [ $? -eq 0 ]; then
        print_success "Oh My Zsh installed successfully"
    else
        print_error "Failed to install Oh My Zsh"
        exit 1
    fi
}

# Install Powerlevel10k theme
install_powerlevel10k() {
    print_step "Installing Powerlevel10k theme..."
    
    local theme_dir="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
    
    if [ -d "$theme_dir" ]; then
        print_success "Powerlevel10k is already installed"
    else
        print_info "Cloning Powerlevel10k repository..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$theme_dir"
        print_success "Powerlevel10k installed successfully"
    fi
}

# Install Zsh plugins
install_plugins() {
    print_step "Installing Zsh plugins..."
    
    local plugins_dir="$HOME/.oh-my-zsh/custom/plugins"
    
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
            print_info "$plugin_name is already installed"
        else
            print_info "Installing $plugin_name..."
            git clone "$plugin_url" "$plugin_path"
            print_success "$plugin_name installed"
        fi
    done
}

# Install required fonts
install_fonts() {
    print_step "Installing recommended fonts..."
    
    print_info "Installing Nerd Fonts for best appearance..."
    # Install noto-fonts and noto-fonts-nerd (AUR alternative if available)
    if command -v yay &>/dev/null || command -v paru &>/dev/null; then
        aur_helper=$(command -v yay || command -v paru)
        print_info "Using AUR helper: $aur_helper"
        $aur_helper -Sy --noconfirm nerd-fonts-noto
        print_success "Nerd Fonts installed via AUR helper"
    else
        print_warning "Consider installing nerd-fonts-noto from AUR for best experience"
        print_info "You can use: yay -Sy nerd-fonts-noto"
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
        print_info "Current shell: $current_shell"
        print_info "Changing to: $zsh_path"
        chsh -s "$zsh_path"
        print_success "Default shell changed to Zsh"
    fi
}

# Display final instructions
print_instructions() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                  Installation Complete!                  ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}✓${NC} Zsh installed"
    echo -e "${GREEN}✓${NC} Oh My Zsh configured"
    echo -e "${GREEN}✓${NC} Powerlevel10k theme installed"
    echo -e "${GREEN}✓${NC} Essential plugins installed"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Close and reopen your terminal for Zsh to become the default"
    echo "2. Run 'p10k configure' to customize your Powerlevel10k theme"
    echo "3. Install a Nerd Font on your system for best appearance"
    echo "   (e.g., Noto Nerd Font, Meslo, or FiraCode Nerd Font)"
    echo ""
}

# Main execution
main() {
    print_banner
    check_system
    check_root
    install_zsh
    install_oh_my_zsh
    install_powerlevel10k
    install_plugins
    install_fonts
    set_default_shell
    print_instructions
}

main
