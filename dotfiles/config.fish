if status is-interactive
    # Commands to run in interactive sessions can go here
    export PATH="/opt/homebrew/bin:$PATH"
    export PATH="$HOME/.local/bin:$PATH"

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

    alias v='nvim'
    alias lg='lazygit'
    alias g='git'

    # -- starship : should be put on last line
    eval "$(starship init fish)"
end
