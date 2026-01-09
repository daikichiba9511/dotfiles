# Commands to run in interactive sessions can go here
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/dotfiles/dotfiles/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="/usr/local/cuda-12/bin:$PATH"
export PATH="$HOME/.juliaup/bin:$PATH"
export PATH="$HOME/.julia/bin:$PATH"

if type mise &>/dev/null
    export PATH="$HOME/.local/share/mise/shims:$PATH"
    eval "$(mise activate fish)"
    eval "$(mise activate --shims)"
end

if type lsd &>/dev/null
    alias ls="lsd"
    alias ll="ls -l"
    alias la="ls -a"
    alias lla="ls -la"
end

# if type sheldon &>/dev/null
#   eval $(sheldon source)
# end

set -gx EDITOR nvim

alias v='nvim'
alias lg='lazygit'
alias g='git'

# -- starship : should be put on last line
eval "$(starship init fish)"
