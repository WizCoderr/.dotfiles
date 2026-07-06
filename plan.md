Plan: macOS Apple Silicon Dotfiles Setup
Current Issues Identified
1. mac_install.sh is corrupted - It's an RTF file instead of a proper shell script
2. install.sh is Linux-only - Uses apt, Linux paths (/home/linuxbrew, /usr/lib/jvm/...), Linux-specific Java
3. aliases has Linux-specific commands - apt update/upgrade, nvidia-smi
4. zshrc has hardcoded Linux paths - linuxbrew, /home/wizcoderr, hardcoded JAVA_HOME
5. Missing macOS package installations - neovim, fastfetch, openjdk@17, ollama, nerd fonts
Proposed Solution
1. Create a new mac_install.sh (proper shell script)
A comprehensive installer that:
- ✅ Detects macOS + Apple Silicon (uname -m == arm64)
- ✅ Installs Homebrew (auto-detects /opt/homebrew for Apple Silicon)
- ✅ Installs packages via Homebrew:
- git, zsh, neovim, fastfetch, openjdk@17, ollama
- fontconfig (for font management)
- ✅ Installs MesloLGS Nerd Font (required for Powerlevel10k icons)
- ✅ Installs Oh My Zsh + Powerlevel10k + 4 Zsh plugins
- ✅ Symlinks all dotfiles (.gitconfig, .aliases, .vimrc, .zshrc, .p10k.zsh)
- ✅ Sets zsh as default shell
- ✅ Configures JAVA_HOME dynamically for Apple Silicon Homebrew path
- ✅ Installs Ollama and pulls the Devstral model
2. Create cross-platform aliases file
- Keep Linux aliases but add macOS equivalents (Homebrew-based)
- Use conditional logic or separate macOS alias file
3. Update zshrc for cross-platform compatibility
- Auto-detect OS and set Homebrew path (/opt/homebrew vs /usr/local vs /home/linuxbrew)
- Dynamic JAVA_HOME detection
- Remove hardcoded user paths (/home/wizcoderr)
4. Keep gitconfig, vimrc, p10k.zsh as-is (they're portable)
File Changes Summary
File	Action
mac_install.sh	REPLACE (currently RTF) - New comprehensive macOS installer
aliases	UPDATE - Add macOS/Homebrew aliases, make cross-platform
zshrc	UPDATE - Auto-detect OS, dynamic paths, dynamic JAVA_HOME
gitconfig	Keep (nvim will be installed via Homebrew)
vimrc	Keep (portable)
p10k.zsh	Keep (portable)
Clarifying Questions
1. Should I create a separate aliases.macos file or make the main aliases cross-platform with conditionals?
2. Do you want to keep the Ollama model pull (hf.co/unsloth/Devstral-Small-2-24B-Instruct-2512-GGUF:IQ2_XXS) or use a different model?
3. Should the installer also set up any macOS-specific tools (e.g., mas for Mac App Store, dockutil for dock management, rectangle for window management)?
4. Do you use any additional tools not in the current scripts that should be installed (e.g., fzf, ripgrep, fd, bat, eza, lazygit, docker, colima)?
5. Should I also create a mac_zsh_install.sh equivalent (standalone Zsh-only installer like the Fedora one)?
Once you confirm, I'll implement all changes.
