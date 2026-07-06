#!/usr/bin/env bash

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_info() {
  echo -e "${BLUE}==>${NC} $1"
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

check_system() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    print_error "This script is intended for macOS."
    exit 1
  fi

  print_success "macOS detected"
}

install_homebrew() {
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  elif command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"
  else
    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ -x /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi

  print_success "Homebrew available at $(command -v brew)"
}

install_packages() {
  print_info "Updating Homebrew..."
  brew update

  print_info "Installing Zsh packages..."
  for package in zsh git curl fastfetch; do
    if brew list --formula "$package" >/dev/null 2>&1; then
      print_success "$package already installed"
    else
      brew install "$package"
    fi
  done
}

configure_default_shell() {
  local zsh_path
  zsh_path="$(command -v zsh)"

  if ! grep -Fxq "$zsh_path" /etc/shells; then
    print_info "Adding $zsh_path to /etc/shells..."
    echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
  fi

  if [[ "${SHELL:-}" == "$zsh_path" ]]; then
    print_success "Zsh is already the default shell"
  else
    print_info "Changing default shell to $zsh_path..."
    chsh -s "$zsh_path" || print_warning "chsh failed; run manually: chsh -s $zsh_path"
  fi
}

install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    print_success "Oh My Zsh already installed"
    return
  fi

  print_info "Installing Oh My Zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_powerlevel10k() {
  local theme_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

  if [[ -d "$theme_dir" ]]; then
    print_success "Powerlevel10k already installed"
  else
    print_info "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$theme_dir"
  fi
}

install_plugins() {
  local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
  local plugins=(
    "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions"
    "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting"
    "zsh-completions|https://github.com/zsh-users/zsh-completions"
    "zsh-history-substring-search|https://github.com/zsh-users/zsh-history-substring-search"
  )

  mkdir -p "$custom_dir"
  print_info "Installing Zsh plugins..."

  for plugin in "${plugins[@]}"; do
    local name="${plugin%%|*}"
    local url="${plugin##*|}"
    local plugin_dir="$custom_dir/$name"

    if [[ -d "$plugin_dir" ]]; then
      print_success "$name already installed"
    else
      git clone "$url" "$plugin_dir"
    fi
  done
}

main() {
  echo ""
  echo "macOS Zsh Installer"
  echo ""

  check_system
  install_homebrew
  install_packages
  install_oh_my_zsh
  install_powerlevel10k
  install_plugins
  configure_default_shell

  echo ""
  print_success "Zsh setup complete"
  print_warning "Open a new terminal or run exec zsh to apply changes."
}

main "$@"
