#!/bin/bash

# Fedora Zsh Installation Script
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
    echo -e "${CYAN}║${NC}     ${MAGENTA}Fedora Zsh + Oh My Zsh Installation Script${NC}        ${CYAN}║${NC}"
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

# Check if running on Fedora
check_system() {
    print_step "Checking system compatibility..."
    
    if [ ! -f /etc/fedora-release ]; then
        print_error "This script is designed for Fedora Linux"
        print_info "Detected: $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2)"
        exit 1
    fi
    
    local fedora_version=$(cat /etc/fedora-release | grep -oP '\d+')
    print_success "Fedora $fedora_version detected"
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
        sudo dnf install -y zsh
        print_success "Zsh installed successfully"
    fi
    
    # Install additional dependencies
    print_info "Installing additional dependencies..."
    sudo dnf install -y git curl wget util-linux-user
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
        print_info "Backing up existing installation..."
        mv "$zsh_dir" "${zsh_dir}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    print_info "Downloading and installing Oh My Zsh..."
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    
    print_success "Oh My Zsh installed successfully"
}

# Install Powerlevel10k theme
install_powerlevel10k() {
    print_step "Installing Powerlevel10k theme..."
    
    local p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    
    if [ -d "$p10k_dir" ]; then
        print_warning "Powerlevel10k is already installed"
        print_info "Updating to latest version..."
        git -C "$p10k_dir" pull --quiet
        print_success "Powerlevel10k updated"
    else
        print_info "Cloning Powerlevel10k repository..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir" --quiet
        print_success "Powerlevel10k installed"
    fi
}

# Install Nerd Fonts (MesloLGS NF)
install_nerd_fonts() {
    print_step "Installing MesloLGS Nerd Font..."
    
    local font_dir="$HOME/.local/share/fonts"
    mkdir -p "$font_dir"
    
    local fonts=(
        "MesloLGS NF Regular.ttf"
        "MesloLGS NF Bold.ttf"
        "MesloLGS NF Italic.ttf"
        "MesloLGS NF Bold Italic.ttf"
    )
    
    local base_url="https://github.com/romkatv/powerlevel10k-media/raw/master"
    local download_needed=false
    
    for font in "${fonts[@]}"; do
        if [ ! -f "$font_dir/$font" ]; then
            download_needed=true
            break
        fi
    done
    
    if [ "$download_needed" = true ]; then
        print_info "Downloading MesloLGS Nerd Font..."
        for font in "${fonts[@]}"; do
            local url_font="${font// /%20}"
            wget -q --show-progress "$base_url/$url_font" -O "$font_dir/$font" 2>&1 | \
                grep --line-buffered -oP '\d+%' | \
                awk '{printf "\rDownloading '"$font"': %s", $0}'
            echo ""
        done
        
        # Update font cache
        print_info "Updating font cache..."
        fc-cache -f "$font_dir"
        print_success "Nerd Font installed"
    else
        print_success "Nerd Font already installed"
    fi
    
    print_warning "Remember to set your terminal font to 'MesloLGS NF'"
}

# Install Zsh plugins
install_plugins() {
    print_step "Installing Zsh plugins..."
    
    local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    
    # Array of plugins: name|repository_url
    local plugins=(
        "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions"
        "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting.git"
        "zsh-completions|https://github.com/zsh-users/zsh-completions"
        "zsh-history-substring-search|https://github.com/zsh-users/zsh-history-substring-search"
    )
    
    for plugin in "${plugins[@]}"; do
        local plugin_name="${plugin%%|*}"
        local plugin_url="${plugin##*|}"
        local plugin_dir="$custom_dir/$plugin_name"
        
        if [ -d "$plugin_dir" ]; then
            print_info "Updating $plugin_name..."
            git -C "$plugin_dir" pull --quiet
            print_success "$plugin_name updated"
        else
            print_info "Installing $plugin_name..."
            git clone "$plugin_url" "$plugin_dir" --quiet
            print_success "$plugin_name installed"
        fi
    done
}

# Configure Zsh as default shell
configure_default_shell() {
    print_step "Configuring default shell..."
    
    local zsh_path=$(which zsh)
    
    if [ "$SHELL" = "$zsh_path" ]; then
        print_success "Zsh is already your default shell"
        return
    fi
    
    print_info "Current shell: $SHELL"
    print_info "Changing default shell to: $zsh_path"
    
    if chsh -s "$zsh_path"; then
        print_success "Default shell changed to Zsh"
        print_warning "You need to log out and log back in for this to take effect"
    else
        print_error "Failed to change default shell"
        print_info "You may need to add zsh to /etc/shells first"
        print_info "Run: echo '$zsh_path' | sudo tee -a /etc/shells"
    fi
}

# Create or update .zshrc
create_zshrc() {
    print_step "Configuring .zshrc..."
    
    local zshrc="$HOME/.zshrc"
    local backup_suffix=".backup.$(date +%Y%m%d_%H%M%S)"
    
    if [ -f "$zshrc" ]; then
        print_info "Backing up existing .zshrc to ${zshrc}${backup_suffix}"
        cp "$zshrc" "${zshrc}${backup_suffix}"
    fi
    
    # Create basic .zshrc with Powerlevel10k and plugins
    cat > "$zshrc" << 'ZSHRC'
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    zsh-history-substring-search
)

source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Load aliases if file exists
[[ ! -f ~/.aliases ]] || source ~/.aliases

# User configuration
# Add your custom configurations below this line
ZSHRC
    
    print_success ".zshrc configured"
}

# Print completion message
print_completion() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                           ║${NC}"
    echo -e "${GREEN}║${NC}              ${MAGENTA}Installation Complete! 🎉${NC}                  ${GREEN}║${NC}"
    echo -e "${GREEN}║                                                           ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Next Steps:${NC}"
    echo ""
    echo -e "  ${YELLOW}1.${NC} Restart your terminal or run:"
    echo -e "     ${GREEN}exec zsh${NC}"
    echo ""
    echo -e "  ${YELLOW}2.${NC} Set your terminal font to:"
    echo -e "     ${GREEN}MesloLGS NF${NC}"
    echo ""
    echo -e "  ${YELLOW}3.${NC} Configure Powerlevel10k (first time only):"
    echo -e "     ${GREEN}p10k configure${NC}"
    echo ""
    echo -e "  ${YELLOW}4.${NC} To reconfigure anytime, run:"
    echo -e "     ${GREEN}p10k configure${NC}"
    echo ""
    echo -e "${CYAN}Installed Components:${NC}"
    echo -e "  ✓ Zsh shell"
    echo -e "  ✓ Oh My Zsh framework"
    echo -e "  ✓ Powerlevel10k theme"
    echo -e "  ✓ MesloLGS Nerd Font"
    echo -e "  ✓ zsh-autosuggestions"
    echo -e "  ✓ zsh-syntax-highlighting"
    echo -e "  ✓ zsh-completions"
    echo -e "  ✓ zsh-history-substring-search"
    echo ""
}

# Main installation
main() {
    print_banner
    
    check_root
    check_system
    install_zsh
    install_oh_my_zsh
    install_powerlevel10k
    install_nerd_fonts
    install_plugins
    create_zshrc
    configure_default_shell
    
    print_completion
}

# Run the script
main "$@"
