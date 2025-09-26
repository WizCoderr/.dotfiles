#!/usr/bin/env bash
set -e

DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup"

FILES=("gitconfig" "aliases" "vimrc" "zshrc")  # zshrc last

# -----------------------------
# Progress bar function
# -----------------------------
progress_bar() {
    local current=$1
    local total=$2
    local width=30
    local filled=$(( (current * width) / total ))
    local empty=$(( width - filled ))
    local bar=$(printf "%0.s█" $(seq 1 $filled))
    local spaces=$(printf "%0.s " $(seq 1 $empty))
    printf "\r🌟 [%s%s] %d/%d" "$bar" "$spaces" "$current" "$total"
}

# -----------------------------
# Install Oh-My-Zsh if missing
# -----------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "📦 Installing Oh-My-Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# -----------------------------
# Install OpenJDK 17 if missing
# -----------------------------
if ! java -version &>/dev/null; then
    echo "☕ Installing OpenJDK 17..."
    sudo apt update
    sudo apt install -y openjdk-17-jdk
fi

# Detect JAVA_HOME dynamically
JAVA_PATH=$(readlink -f $(which java) | sed "s:bin/java::")
if ! grep -q "JAVA_HOME" "$HOME/.zshrc"; then
    echo "export JAVA_HOME=$JAVA_PATH" >> "$HOME/.zshrc"
    echo 'export PATH=$JAVA_HOME/bin:$PATH' >> "$HOME/.zshrc"
fi
echo "✅ JAVA_HOME set to $JAVA_PATH"

# -----------------------------
# Backup & symlink dotfiles
# -----------------------------
mkdir -p "$BACKUP_DIR"

total=${#FILES[@]}
current=0

for file in "${FILES[@]}"; do
    src="$DOTFILES_DIR/$file"
    dest="$HOME/.$file"

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        echo -e "\n📦 Backing up $dest to $BACKUP_DIR"
        mv "$dest" "$BACKUP_DIR/"
    fi

    echo -e "\n🔗 Linking $src -> $dest"
    ln -s "$src" "$dest"

    current=$((current + 1))
    progress_bar $current $total
    sleep 0.3
done

# -----------------------------
# Install Powerlevel10k theme
# -----------------------------
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
    echo -e "\n🎨 Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
        $HOME/.oh-my-zsh/custom/themes/powerlevel10k
fi

# -----------------------------
# Install Zsh plugins
# -----------------------------
echo "🔌 Installing zsh plugins..."
PLUGINS=(
"https://github.com/zsh-users/zsh-autosuggestions"
"https://github.com/zsh-users/zsh-syntax-highlighting"
"https://github.com/zsh-users/zsh-completions"
"https://github.com/zsh-users/zsh-history-substring-search"
)

for plugin in "${PLUGINS[@]}"; do
    folder="$HOME/.oh-my-zsh/custom/plugins/$(basename $plugin)"
    if [ ! -d "$folder" ]; then
        git clone "$plugin" "$folder"
    fi
done

# -----------------------------
# Link Powerlevel10k config if exists
# -----------------------------
if [ -f "$DOTFILES_DIR/p10k.zsh" ]; then
    ln -sf "$DOTFILES_DIR/p10k.zsh" "$HOME/.p10k.zsh"
fi

echo -e "\n✅ Dotfiles + Java setup installed successfully!"
echo "👉 Backups are in $BACKUP_DIR"
echo "💡 Restart your terminal or run 'exec zsh' to apply changes"
