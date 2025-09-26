# 📂 Dotfiles

This repository contains **portable configuration files** for Zsh, Vim, Git, and shell aliases.
It includes **Oh-My-Zsh**, **Powerlevel10k theme**, **Nerd Fonts**, and useful Zsh plugins for a modern development environment.
Works on **WSL**, **Mac**, and Linux.

---

## 🔹 Features

* **Zsh** as default shell
* **Oh-My-Zsh** framework
* **Powerlevel10k** theme with Nerd Fonts support
* Plugins:

  * `zsh-autosuggestions`
  * `zsh-syntax-highlighting`
  * `zsh-completions`
  * `zsh-history-substring-search`
* **Git config and aliases**
* **Vim config**
* **Portable Android SDK paths** for WSL/Mac
* **Install script with progress bar**
* Backup of existing dotfiles

---

## 🔹 Files Included

| File         | Description                                                                        |
| ------------ | ---------------------------------------------------------------------------------- |
| `zshrc`      | Zsh configuration with Oh-My-Zsh, Powerlevel10k, plugins, SDK paths                |
| `gitconfig`  | Git configuration with aliases and user info                                       |
| `aliases`    | Useful shell and Git command shortcuts                                             |
| `vimrc`      | Basic Vim configuration                                                            |
| `p10k.zsh`   | Powerlevel10k saved configuration (optional)                                       |
| `install.sh` | Installer script: backs up old configs, symlinks files, installs theme and plugins |

---

## 🔹 Installation

### 1. Prerequisites

**WSL (Ubuntu/Debian):**

```bash
sudo apt update
sudo apt install -y git curl wget zsh fonts-powerline
```

**Mac:**

```bash
brew update
brew install git zsh curl wget
brew tap homebrew/cask-fonts
brew install --cask font-meslo-lg-nerd-font
```

---

### 2. Clone the repository

```bash
cd ~
git clone https://github.com/<your-username>/dotfiles.git ~/.dotfiles
```

---

### 3. Make installer executable

```bash
chmod +x ~/.dotfiles/install.sh
```

---

### 4. Run the installer

```bash
~/.dotfiles/install.sh
```

* Backs up existing dotfiles to `~/.dotfiles_backup`
* Creates symlinks to new dotfiles
* Installs **Powerlevel10k** and Zsh plugins
* Shows progress bar

---

### 5. Change default shell to Zsh

```bash
chsh -s $(which zsh)
exec zsh
```

---

### 6. Configure Powerlevel10k

* After `exec zsh`, the **Powerlevel10k wizard** will run.
* Pick font → make sure terminal uses **MesloLGS NF Nerd Font**
* Choose prompt style, colors, and segments
* Save config → creates `~/.p10k.zsh`

Optional: Add it to dotfiles for portability:

```bash
mv ~/.p10k.zsh ~/.dotfiles/p10k.zsh
ln -s ~/.dotfiles/p10k.zsh ~/.p10k.zsh
```

---

## 🔹 Verify Setup

```bash
zsh --version
echo $SHELL
git --version
adb version  # if Android SDK installed
p10k configure  # re-run wizard if needed
```

---

## 🔹 Updating Dotfiles

To pull the latest version:

```bash
cd ~/.dotfiles
git pull origin main
~/.dotfiles/install.sh
```

---