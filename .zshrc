# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export EDITOR=nvim
export PATH="$HOME/.local/bin:$PATH"
# eval "$(starship init zsh)"

# ${UserConfigDir}/zsh/.zshrc
autoload -U compinit && compinit
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
source <(carapace _carapace)


# Alias'sss
alias vim="nvim"
alias vi="nvim"
alias config="nvim ~/.zshrc"
alias configsource="source ~/.zshrc"
alias wconfig="nvim ~/.config/hypr/hyprland.conf"
alias nconfig="nvim ~/.config/nvim/init.lua"
alias reload-waybar='killall waybar; nohup waybar >/dev/null 2>&1 &'
alias flcollection='cd "/home/maritsch/.var/app/com.usebottles.bottles/data/bottles/bottles/Fruity/drive_c/users/steamuser/Documents/Collection"'

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"

  local cwd
  cwd="$(cat -- "$tmp")"

  if [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
    builtin cd -- "$cwd"
  fi

  rm -f -- "$tmp"
}

autoload -U add-zsh-hook

auto_venv() {
    local dir="$PWD"
    local venv=""

    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/.venv" ]]; then
            venv="$dir/.venv"
            break
        elif [[ -d "$dir/venv" ]]; then
            venv="$dir/venv"
            break
        fi

        dir="${dir:h}"
    done

    if [[ -n "$venv" ]]; then
        venv="${venv:A}"

        if [[ "$VIRTUAL_ENV" != "$venv" ]]; then
            [[ -n "$VIRTUAL_ENV" ]] && deactivate 2>/dev/null
            source "$venv/bin/activate"
        fi
    elif [[ -n "$VIRTUAL_ENV" ]]; then
        deactivate
    fi
}

add-zsh-hook chpwd auto_venv
auto_venv
source ${ZDOTDIR:-$HOME}/.powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

updateall() {
  echo "==> System packages"
  sudo pacman -Syu

  if command -v yay >/dev/null 2>&1; then
    echo "==> AUR packages"
    yay -Sua
  elif command -v paru >/dev/null 2>&1; then
    echo "==> AUR packages"
    paru -Sua
  fi

  if command -v flatpak >/dev/null 2>&1; then
    echo "==> Flatpaks"
    flatpak update
  fi
}
