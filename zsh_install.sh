#!/bin/bash

# Define colors for better output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}--- Starting Zsh and Oh My Zsh installation script for WSL ---${NC}"

# 1. Update system packages
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# 2. Install necessary dependencies (git, curl, zsh)
echo "Installing Zsh and necessary dependencies..."
sudo apt install zsh curl git -y

# Check if Zsh installed successfully
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Zsh installed successfully.${NC}"
else
    echo "Failed to install Zsh. Exiting script."
    exit 1
fi

# 3. Install Oh My Zsh via their automated script
echo "Installing Oh My Zsh framework..."
# The silent install avoids prompts during script execution for a smooth run
RUNZSH=no CHSH=no sh -c "$(curl -fsSL raw.githubusercontent.com)"

# Check if Oh My Zsh installed successfully
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Oh My Zsh installed successfully.${NC}"
else
    echo "Failed to install Oh My Zsh. Check connectivity and run manually if needed."
fi

# 4. Set Zsh as the default shell for the current user
echo "Setting Zsh as the default shell..."
chsh -s $(which zsh)

echo -e "${GREEN}--- Installation complete ---${NC}"
echo "You must close and reopen your WSL terminal for Zsh to become the default shell."
echo "Remember to install a Nerd Font on Windows and configure your Windows Terminal for the best experience."
