#!/usr/bin/env bash

set -euo pipefail

# mac_zsh_install.sh
# Installer for macOS: installs Homebrew (if missing), zsh, and Oh My Zsh,
# adds brew zsh to /etc/shells when required and sets it as the default shell.

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "${GREEN}--- Starting Zsh installer for macOS ---${NC}"

if [[ "$(uname)" != "Darwin" ]]; then
  echo -e "${YELLOW}This script is intended for macOS (Darwin). Exiting.${NC}"
  exit 1
fi

# Ensure curl and git are present (macOS usually has them)
if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required but not found. Please install curl and re-run."
  exit 1
fi

# Install Homebrew if missing
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found — installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add Homebrew to PATH for this session (handles Intel/Apple Silicon)
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  echo "Homebrew found at: $(command -v brew)"
fi

echo "Updating Homebrew..."
brew update || true

echo "Installing zsh, git, and curl via Homebrew (if not present)..."
brew install zsh git curl || true

# Determine zsh path to use
ZSH_PATH="$(command -v zsh)"
echo "Using zsh: ${ZSH_PATH}"

# Ensure the zsh path is listed in /etc/shells
if ! grep -Fxq "${ZSH_PATH}" /etc/shells; then
  echo "Adding ${ZSH_PATH} to /etc/shells (requires sudo)..."
  sudo sh -c "echo ${ZSH_PATH} >> /etc/shells"
fi

echo "Installing Oh My Zsh (non-interactive)..."
RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Setting zsh as the default shell for the current user..."
chsh -s "${ZSH_PATH}" || echo "chsh failed; you may need to run it manually: chsh -s ${ZSH_PATH}"

echo -e "${GREEN}--- Installation finished.${NC}"
echo "Next steps (optional):"
echo " - Open a new Terminal window to start using zsh."
echo " - If you maintain dotfiles here, consider symlinking your .zshrc and other files from this repo."

exit 0
