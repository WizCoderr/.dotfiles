#!/usr/bin/env bash

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
BACKUP_DIR="${BACKUP_DIR:-$HOME/.dotfiles_backup}"

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
    print_error "This installer is intended for macOS."
    exit 1
  fi

  if [[ "$(uname -m)" != "arm64" ]]; then
    print_error "This installer is intended for Apple Silicon Macs."
    exit 1
  fi

  print_success "macOS Apple Silicon detected"
}

install_homebrew() {
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"
  else
    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  print_success "Homebrew available at $(command -v brew)"
}

install_packages() {
  local packages=(
    git
    zsh
    neovim
    fastfetch
    openjdk@17
    fontconfig
  )

  print_info "Updating Homebrew..."
  brew update

  print_info "Installing core packages..."
  for package in "${packages[@]}"; do
    if brew list --formula "$package" >/dev/null 2>&1; then
      print_success "$package already installed"
    else
      brew install "$package"
    fi
  done
}

install_nerd_fonts() {
  local font_dir="$HOME/Library/Fonts"
  local base_url="https://github.com/romkatv/powerlevel10k-media/raw/master"
  local fonts=(
    "MesloLGS NF Regular.ttf"
    "MesloLGS NF Bold.ttf"
    "MesloLGS NF Italic.ttf"
    "MesloLGS NF Bold Italic.ttf"
  )

  mkdir -p "$font_dir"
  print_info "Installing MesloLGS Nerd Font..."

  for font in "${fonts[@]}"; do
    if [[ -f "$font_dir/$font" ]]; then
      print_success "$font already installed"
      continue
    fi

    curl -fsSL "$base_url/${font// /%20}" -o "$font_dir/$font"
  done

  if command -v fc-cache >/dev/null 2>&1; then
    fc-cache -f "$font_dir" >/dev/null 2>&1 || true
  fi

  print_success "MesloLGS Nerd Font installed"
}

install_oh_my_zsh() {
  local omz_dir="$HOME/.oh-my-zsh"
  local omz_repo="https://github.com/ohmyzsh/ohmyzsh.git"
  local tmp_dir
  local backup_dir

  if [[ -f "$omz_dir/oh-my-zsh.sh" ]]; then
    print_success "Oh My Zsh already installed"
    return
  fi

  tmp_dir="$(mktemp -d)"
  print_info "Downloading Oh My Zsh..."
  git clone --depth=1 "$omz_repo" "$tmp_dir/oh-my-zsh"

  if [[ -d "$omz_dir" ]]; then
    backup_dir="$BACKUP_DIR/oh-my-zsh.partial.$(date +%Y%m%d%H%M%S)"
    print_warning "Found incomplete Oh My Zsh install at $omz_dir"
    mkdir -p "$BACKUP_DIR"
    mv "$omz_dir" "$backup_dir"
    mv "$tmp_dir/oh-my-zsh" "$omz_dir"

    if [[ -d "$backup_dir/custom" ]]; then
      rm -rf "$omz_dir/custom"
      mv "$backup_dir/custom" "$omz_dir/custom"
      print_success "Preserved existing Oh My Zsh custom plugins and themes"
    fi

    print_success "Repaired Oh My Zsh install"
  else
    print_info "Installing Oh My Zsh..."
    mv "$tmp_dir/oh-my-zsh" "$omz_dir"
    print_success "Oh My Zsh installed"
  fi

  rm -rf "$tmp_dir"
}

install_powerlevel10k() {
  local theme_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

  if [[ -d "$theme_dir" ]]; then
    print_success "Powerlevel10k already installed"
    return
  fi

  print_info "Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$theme_dir"
}

install_zsh_plugins() {
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

backup_file() {
  local target="$1"

  if [[ -e "$target" || -L "$target" ]]; then
    mkdir -p "$BACKUP_DIR"
    mv "$target" "$BACKUP_DIR/$(basename "$target").$(date +%Y%m%d%H%M%S)"
    print_success "Backed up $target"
  fi
}

link_dotfiles() {
  local files=(
    "gitconfig:.gitconfig"
    "aliases:.aliases"
    "vimrc:.vimrc"
    "zshrc:.zshrc"
    "p10k.zsh:.p10k.zsh"
  )

  print_info "Linking dotfiles from $DOTFILES_DIR..."

  for file in "${files[@]}"; do
    local source_name="${file%%:*}"
    local target_name="${file##*:}"
    local source="$DOTFILES_DIR/$source_name"
    local target="$HOME/$target_name"

    if [[ ! -f "$source" ]]; then
      print_warning "$source not found, skipping"
      continue
    fi

    if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
      print_success "$target already linked"
      continue
    fi

    backup_file "$target"
    ln -s "$source" "$target"
    print_success "Linked $target"
  done
}

configure_java_home() {
  local openjdk_prefix
  openjdk_prefix="$(brew --prefix openjdk@17)"

  print_success "OpenJDK 17 installed at $openjdk_prefix"
  print_success "JAVA_HOME will be set dynamically by .zshrc"
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

main() {
  echo ""
  echo "macOS Apple Silicon Dotfiles Installer"
  echo ""

  check_system
  install_homebrew
  install_packages
  install_nerd_fonts
  install_oh_my_zsh
  install_powerlevel10k
  install_zsh_plugins
  link_dotfiles
  configure_java_home
  configure_default_shell

  echo ""
  print_success "macOS dotfiles setup complete"
  print_warning "Set your terminal font to MesloLGS NF, then restart your terminal or run exec zsh."
}

main "$@"
