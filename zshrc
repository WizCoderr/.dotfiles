# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

path_prepend() {
  [[ -d "$1" ]] || return
  case ":$PATH:" in
    *":$1:"*) ;;
    *) export PATH="$1:$PATH" ;;
  esac
}

# -----------------------------
# Homebrew
# -----------------------------
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
elif [[ -x "$HOME/.linuxbrew/bin/brew" ]]; then
  eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
fi

# -----------------------------
# Java
# -----------------------------
if [[ -z "${JAVA_HOME:-}" ]]; then
  if [[ "$(uname -s)" == "Darwin" ]] && /usr/libexec/java_home -v 17 >/dev/null 2>&1; then
    export JAVA_HOME="$(/usr/libexec/java_home -v 17)"
  elif command -v brew >/dev/null 2>&1 && [[ -d "$(brew --prefix openjdk@17 2>/dev/null)" ]]; then
    export JAVA_HOME="$(brew --prefix openjdk@17)"
  elif [[ -d /usr/lib/jvm ]]; then
    for java_dir in /usr/lib/jvm/java-17-openjdk* /usr/lib/jvm/*-17-*; do
      if [[ -d "$java_dir" ]]; then
        export JAVA_HOME="$java_dir"
        break
      fi
    done
  fi
fi

if [[ -n "${JAVA_HOME:-}" ]]; then
  path_prepend "$JAVA_HOME/bin"
fi

# -----------------------------
# Zsh Configuration
# -----------------------------
if [[ -d "$HOME/.oh-my-zsh" ]]; then
  export ZSH="$HOME/.oh-my-zsh"
  ZSH_THEME="strug"

  plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    zsh-history-substring-search
    wikipidia
  )

  [[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"
fi

# -----------------------------
# Optional tools
# -----------------------------
if [[ -f "$HOME/.asdf/asdf.sh" ]]; then
  source "$HOME/.asdf/asdf.sh"
  [[ -f "$HOME/.asdf/completions/asdf.bash" ]] && source "$HOME/.asdf/completions/asdf.bash"
fi

if [[ -s "$HOME/.bun/_bun" ]]; then
  source "$HOME/.bun/_bun"
fi

export BUN_INSTALL="$HOME/.bun"
path_prepend "$BUN_INSTALL/bin"
path_prepend "/usr/local/go/bin"
path_prepend "$HOME/develop/flutter/bin"

if [[ -f "$HOME/.local/bin/env" ]]; then
  source "$HOME/.local/bin/env"
fi

# -----------------------------
# Aliases and defaults
# -----------------------------
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

export EDITOR="nvim"
export HISTSIZE=10000
export SAVEHIST=10000


[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/wizcoderr/.lmstudio/bin"
# End of LM Studio CLI section


# bun completions
[ -s "/Users/wizcoderr/.bun/_bun" ] && source "/Users/wizcoderr/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
