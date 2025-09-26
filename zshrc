# -----------------------------
# Zsh Configuration (Portable)
# -----------------------------

# Only set ZSH if it exists
if [ -d "$HOME/.oh-my-zsh" ]; then
    export ZSH="$HOME/.oh-my-zsh"
    ZSH_THEME="powerlevel10k/powerlevel10k"
    plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions zsh-history-substring-search)
    source $ZSH/oh-my-zsh.sh
fi

# Load Powerlevel10k config if exists
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# -----------------------------
# SDKs / PATH
# -----------------------------
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    export ANDROID_HOME=$HOME/Android
elif [[ "$OSTYPE" == "darwin"* ]]; then
    export ANDROID_HOME=$HOME/Library/Android/sdk
fi
export PATH=$ANDROID_HOME/platform-tools:$PATH

# -----------------------------
# ASDF (optional)
# -----------------------------
if [ -f "$HOME/.asdf/asdf.sh" ]; then
    . "$HOME/.asdf/asdf.sh"
    . "$HOME/.asdf/completions/asdf.bash"
fi

# -----------------------------
# Aliases
# -----------------------------
[ -f ~/.aliases ] && source ~/.aliases

# Editor
export EDITOR="nvim"

# History
export HISTSIZE=10000
export SAVEHIST=10000
