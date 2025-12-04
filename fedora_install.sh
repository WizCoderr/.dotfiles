#!/bin/bash

# Fedora Dotfiles Installer
# Compatible with Fedora Linux

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Check if running on Fedora
check_fedora() {
    if [ ! -f /etc/fedora-release ]; then
        print_error "This script is designed for Fedora Linux."
        print_info "For other distributions, please use the appropriate install script."
        exit 1
    fi
    print_success "Fedora system detected"
}

# Backup existing dotfiles
backup_dotfiles() {
    print_info "Backing up existing dotfiles..."
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
    print_info "Installing required packages..."
    
    # Update package database
    print_info "Updating package database..."
    sudo dnf check-update || true
    
    # Install packages
    local packages=(
        "git"
        "curl"
        "wget"
        "zsh"
        "util-linux-user"  # for chsh
        "fontconfig"       # for font management
    )
    
    for pkg in "${packages[@]}"; do
        if ! rpm -q "$pkg" &>/dev/null; then
            print_info "Installing $pkg..."
            sudo dnf install -y "$pkg"
        else
            print_success "$pkg already installed"
        fi
    done
    
    print_success "All required packages installed"
}

# Install Nerd Fonts
install_nerd_fonts() {
    print_info "Installing MesloLGS Nerd Font..."
    
    local font_dir="$HOME/.local/share/fonts"
    mkdir -p "$font_dir"
    
    local fonts=(
        "MesloLGS%20NF%20Regular.ttf"
        "MesloLGS%20NF%20Bold.ttf"
        "MesloLGS%20NF%20Italic.ttf"
        "MesloLGS%20NF%20Bold%20Italic.ttf"
    )
    
    local base_url="https://github.com/romkatv/powerlevel10k-media/raw/master"
    
    for font in "${fonts[@]}"; do
        local font_file="${font//%20/ }"
        if [ ! -f "$font_dir/$font_file" ]; then
            print_info "Downloading $font_file..."
            wget -q "$base_url/$font" -O "$font_dir/$font_file"
        fi
    done
    
    # Update font cache
    fc-cache -fv "$font_dir" &>/dev/null
    
    print_success "Nerd Fonts installed"
    print_warning "Remember to set your terminal font to 'MesloLGS NF'"
}

# Install Oh My Zsh
install_oh_my_zsh() {
    print_info "Installing Oh My Zsh..."
    
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_warning "Oh My Zsh already installed, skipping..."
        return
    fi
    
    # Install Oh My Zsh (unattended)
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    print_success "Oh My Zsh installed"
}

# Install Powerlevel10k theme
install_powerlevel10k() {
    print_info "Installing Powerlevel10k theme..."
    
    local p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    
    if [ -d "$p10k_dir" ]; then
        print_warning "Powerlevel10k already installed, updating..."
        git -C "$p10k_dir" pull -q
    else
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir" -q
    fi
    
    print_success "Powerlevel10k theme installed"
}

# Install Zsh plugins
install_zsh_plugins() {
    print_info "Installing Zsh plugins..."
    
    local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    local plugins=(
        "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions"
        "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting"
        "zsh-completions:https://github.com/zsh-users/zsh-completions"
        "zsh-history-substring-search:https://github.com/zsh-users/zsh-history-substring-search"
    )
    
    for plugin_info in "${plugins[@]}"; do
        local plugin_name="${plugin_info%%:*}"
        local plugin_url="${plugin_info##*:}"
        local plugin_dir="$custom_dir/plugins/$plugin_name"
        
        if [ -d "$plugin_dir" ]; then
            print_warning "$plugin_name already installed, updating..."
            git -C "$plugin_dir" pull -q
        else
            print_info "Installing $plugin_name..."
            git clone "$plugin_url" "$plugin_dir" -q
        fi
    done
    
    print_success "All Zsh plugins installed"
}

# Create symlinks for dotfiles
create_symlinks() {
    print_info "Creating symlinks for dotfiles..."
    
    local dotfiles_dir="$HOME/.dotfiles"
    local files=(
        "zshrc:.zshrc"
        "gitconfig:.gitconfig"
        "aliases:.aliases"
        "vimrc:.vimrc"
    )
    
    for file_info in "${files[@]}"; do
        local source="${file_info%%:*}"
        local target="${file_info##*:}"
        
        if [ -f "$dotfiles_dir/$source" ]; then
            ln -sf "$dotfiles_dir/$source" "$HOME/$target"
            print_success "Linked $target"
        else
            print_warning "Source file $source not found, skipping..."
        fi
    done
    
    # Link p10k config if it exists
    if [ -f "$dotfiles_dir/p10k.zsh" ]; then
        ln -sf "$dotfiles_dir/p10k.zsh" "$HOME/.p10k.zsh"
        print_success "Linked .p10k.zsh"
    fi
}

# Change default shell to zsh
change_shell() {
    if [ "$SHELL" != "$(which zsh)" ]; then
        print_info "Changing default shell to zsh..."
        chsh -s "$(which zsh)"
        print_success "Default shell changed to zsh"
        print_warning "Please log out and log back in for the change to take effect"
    else
        print_success "Default shell is already zsh"
    fi
}

# Main installation process
main() {
    local total_steps=10
    local current_step=0
    
    echo ""
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║                                                        ║"
    echo "║         Fedora Dotfiles Installation Script           ║"
    echo "║                                                        ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo ""
    
    # Step 1: Check Fedora
    current_step=$((current_step + 1))
    show_progress $current_step $total_steps "Checking system..."
    check_fedora
    
    # Step 2: Backup
    current_step=$((current_step + 1))
    show_progress $current_step $total_steps "Backing up existing dotfiles..."
    backup_dotfiles
    
    # Step 3: Install packages
    current_step=$((current_step + 1))
    show_progress $current_step $total_steps "Installing required packages..."
    install_packages
    
    # Step 4: Install Nerd Fonts
    current_step=$((current_step + 1))
    show_progress $current_step $total_steps "Installing Nerd Fonts..."
    install_nerd_fonts
    
    # Step 5: Install Oh My Zsh
    current_step=$((current_step + 1))
    show_progress $current_step $total_steps "Installing Oh My Zsh..."
    install_oh_my_zsh
    
    # Step 6: Install Powerlevel10k
    current_step=$((current_step + 1))
    show_progress $current_step $total_steps "Installing Powerlevel10k..."
    install_powerlevel10k
    
    # Step 7: Install plugins
    current_step=$((current_step + 1))
    show_progress $current_step $total_steps "Installing Zsh plugins..."
    install_zsh_plugins
    
    # Step 8: Create symlinks
    current_step=$((current_step + 1))
    show_progress $current_step $total_steps "Creating symlinks..."
    create_symlinks
    
    # Step 9: Change shell
    current_step=$((current_step + 1))
    show_progress $current_step $total_steps "Changing default shell..."
    change_shell
    
    # Step 10: Complete
    current_step=$((current_step + 1))
    show_progress $current_step $total_steps "Installation complete!"
    
    echo ""
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║                                                        ║"
    echo "║              Installation Successful! 🎉               ║"
    echo "║                                                        ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo ""
    print_info "Next steps:"
    echo "  1. Restart your terminal or run: exec zsh"
    echo "  2. Set your terminal font to 'MesloLGS NF'"
    echo "  3. Run 'p10k configure' to customize your prompt"
    echo ""
}

# Run main function
main "$@"
