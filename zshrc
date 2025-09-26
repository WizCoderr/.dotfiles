# -----------------------------
# Oh-My-Zsh + Powerlevel10k
# -----------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  zsh-history-substring-search
)

source $ZSH/oh-my-zsh.sh

# Load Powerlevel10k config if exists
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# -----------------------------
# SDKs / PATH
# -----------------------------
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    export ANDROID_HOME=$HOME/Android
elif [[ "$OSTYPE" == "darwin"* ]]; then
    export ANDROID_HOME=$HOME/Library/Android/sdk
fi
export PATH=$ANDROID_HOME/platform-tools:$PATH

# ASDF (Language Version Manager)
. "$HOME/.asdf/asdf.sh"

# Aliases
source ~/.aliases

# Editor
export EDITOR="nvim"

# Custom prompt tweaks
export HISTSIZE=10000
export SAVEHIST=10000

