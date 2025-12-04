# Dotfiles for Fedora Linux

This guide covers installation and setup of dotfiles on Fedora Linux systems.

## 🚀 Quick Start

```bash
# Clone the repository
cd ~
git clone https://github.com/WizCoderr/.dotfiles.git ~/.dotfiles

# Make scripts executable
chmod +x ~/.dotfiles/install-fedora.sh
chmod +x ~/.dotfiles/zsh_install-fedora.sh

# Run the installer
~/.dotfiles/install-fedora.sh
```

## 📦 What Gets Installed

### System Packages (via DNF)
- `git` - Version control
- `curl` - Data transfer tool
- `wget` - File downloader
- `zsh` - Z shell
- `util-linux-user` - For changing default shell
- `fontconfig` - Font configuration

### Zsh Ecosystem
- **Oh My Zsh** - Zsh configuration framework
- **Powerlevel10k** - Fast and beautiful prompt theme
- **MesloLGS NF** - Nerd Font for terminal icons

### Zsh Plugins
- `zsh-autosuggestions` - Command suggestions based on history
- `zsh-syntax-highlighting` - Syntax highlighting for commands
- `zsh-completions` - Additional completion definitions
- `zsh-history-substring-search` - Search through command history

## 🔧 Installation Options

### Option 1: Full Installation (Recommended)

Complete setup with dotfiles, themes, plugins, and fonts:

```bash
~/.dotfiles/install-fedora.sh
```

This script will:
1. ✅ Check if running on Fedora
2. 📦 Backup existing dotfiles to `~/.dotfiles_backup`
3. 🔽 Install required packages using DNF
4. 🔤 Install MesloLGS Nerd Font
5. 🐚 Install Oh My Zsh
6. 🎨 Install Powerlevel10k theme
7. 🔌 Install Zsh plugins
8. 🔗 Create symlinks for dotfiles
9. ⚙️ Change default shell to Zsh

### Option 2: Zsh Only Installation

If you only want to install Zsh with Oh My Zsh and plugins:

```bash
~/.dotfiles/zsh_install-fedora.sh
```

This is perfect if you:
- Already have your own dotfiles
- Just want a modern Zsh setup
- Want to test before full installation

## ⚙️ Post-Installation

### 1. Restart Your Terminal

```bash
exec zsh
```

### 2. Configure Terminal Font

Set your terminal emulator to use **MesloLGS NF** font:

#### GNOME Terminal
1. Edit → Preferences → Profile → Text
2. Enable "Custom font"
3. Select "MesloLGS NF Regular"

#### Konsole (KDE)
1. Settings → Edit Current Profile
2. Appearance → Select Font → "MesloLGS NF"

#### Alacritty
Add to `~/.config/alacritty/alacritty.yml`:
```yaml
font:
  normal:
    family: MesloLGS NF
```

#### kitty
Add to `~/.config/kitty/kitty.conf`:
```
font_family MesloLGS NF
```

### 3. Configure Powerlevel10k

On first launch, the configuration wizard will run automatically. Or run manually:

```bash
p10k configure
```

Choose your preferred prompt style, colors, and features.

## 📁 File Structure

```
~/.dotfiles/
├── install-fedora.sh           # Main Fedora installer
├── zsh_install-fedora.sh       # Standalone Zsh installer
├── zshrc                        # Zsh configuration
├── gitconfig                    # Git configuration
├── aliases                      # Shell aliases
├── vimrc                        # Vim configuration
├── p10k.zsh                     # Powerlevel10k config (optional)
└── README-FEDORA.md            # This file
```

## 🔄 Updating

### Update Dotfiles
```bash
cd ~/.dotfiles
git pull origin main
~/.dotfiles/install-fedora.sh
```

### Update Oh My Zsh
```bash
omz update
```

### Update Powerlevel10k
```bash
git -C ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k pull
```

### Update All Plugins
```bash
cd ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins
for plugin in */; do
    echo "Updating $plugin..."
    git -C "$plugin" pull
done
```

## 🆚 Differences from Ubuntu/Debian Version

| Feature | Ubuntu/Debian | Fedora |
|---------|--------------|--------|
| Package Manager | `apt` | `dnf` |
| Package Names | `fonts-powerline` | Fonts installed manually |
| User Utils | Included in base | `util-linux-user` package |
| Font Directory | Same | `~/.local/share/fonts` |
| Font Cache | `fc-cache -fv` | `fc-cache -f` |

## 🛠️ Troubleshooting

### Zsh Not Default Shell After Installation

```bash
# Check available shells
cat /etc/shells

# If zsh is not listed, add it
echo $(which zsh) | sudo tee -a /etc/shells

# Change shell
chsh -s $(which zsh)

# Log out and log back in
```

### Font Not Showing Icons

1. Verify font is installed:
   ```bash
   fc-list | grep -i meslo
   ```

2. If not found, reinstall fonts:
   ```bash
   ~/.dotfiles/zsh_install-fedora.sh
   ```

3. Make sure your terminal is using "MesloLGS NF"

### Plugins Not Working

Source your `.zshrc` again:
```bash
source ~/.zshrc
```

Or check if plugins are installed:
```bash
ls ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins
```

### Permissions Issues

Some directories might need correct permissions:
```bash
chmod -R 755 ~/.oh-my-zsh
chmod 644 ~/.zshrc
```

## 🎨 Customization

### Adding Custom Aliases

Edit `~/.dotfiles/aliases` or add to `~/.zshrc`:

```bash
# Add at the end of ~/.zshrc
alias update='sudo dnf update'
alias install='sudo dnf install'
alias search='dnf search'
```

### Changing Theme

Edit `~/.zshrc` and change the `ZSH_THEME` line:

```bash
# For other themes
ZSH_THEME="robbyrussell"

# For Powerlevel10k (recommended)
ZSH_THEME="powerlevel10k/powerlevel10k"
```

### Adding More Plugins

1. Clone the plugin to the custom directory:
   ```bash
   git clone <plugin-repo> ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/<plugin-name>
   ```

2. Add to plugins array in `~/.zshrc`:
   ```bash
   plugins=(
       git
       zsh-autosuggestions
       zsh-syntax-highlighting
       <plugin-name>
   )
   ```

3. Reload configuration:
   ```bash
   source ~/.zshrc
   ```

## 📝 Notes

- **SELinux**: These scripts work with SELinux in enforcing mode
- **Wayland**: Works with both X11 and Wayland sessions
- **Firewalld**: No firewall rules needed
- **Backups**: Always creates backups in `~/.dotfiles_backup`

## 🆘 Getting Help

If you encounter issues:

1. Check the error message carefully
2. Ensure you're running Fedora (the script checks this)
3. Make sure you have sudo privileges
4. Check the troubleshooting section above
5. Open an issue on GitHub with:
   - Fedora version: `cat /etc/fedora-release`
   - Error messages
   - Steps to reproduce

## 📚 Additional Resources

- [Oh My Zsh Documentation](https://github.com/ohmyzsh/ohmyzsh/wiki)
- [Powerlevel10k Documentation](https://github.com/romkatv/powerlevel10k)
- [Fedora User Documentation](https://docs.fedoraproject.org/)
- [Nerd Fonts](https://www.nerdfonts.com/)

## ✅ Testing

Test your installation:

```bash
# Check Zsh version
zsh --version

# Check current shell
echo $SHELL

# Check Git
git --version

# Test plugin - type a command and see suggestions
ls
# (arrow keys should show history)

# Check font
echo -e "\ue0b0 \u00b1 \ue0a0 \u27a6 \u2718 \u26a1 \u2699"
# Should display icons if font is working
```

## 🔐 Security

- Scripts run with regular user privileges
- Sudo required only for package installation
- No sensitive data in dotfiles
- Git credentials stored separately in `~/.gitlocal`

---

**Enjoy your new Zsh setup on Fedora!** 🎉
