# ~/.config/fish/config.fish

### ENVIRONMENT VARIABLES ###
set -x PATH $HOME/bin /usr/local/bin /usr/local/go/bin $HOME/go/bin $HOME/.local/bin $PATH
set -x SSH_AUTH_SOCK $XDG_RUNTIME_DIR/ssh-agent.socket
#set -x GO111MODULE on
#set -x GOPRIVATE gitlab.advancedclimate.nl
set -g fish_greeting


### EDITOR ###
set -x EDITOR nvim
set -x TERM xterm-256color

### ALIASES ###
alias activate "source .env/bin/activate"
alias ls "exa"
alias vim "nvim"
alias gst "git status"
alias tsserver "npx tsserver"

set _fzf_colors \
    fg:#dcd7ba \
    bg:#1e1f28 \
    hl:#9cabca \
    fg+:#727169 \
    bg+:#2a2a37 \
    hl+:#7e9cd8 \
    info:#7aa89f \
    prompt:#e46876 \
    pointer:#7e9cd8 \
    marker:#98bb6c \
    spinner:#938aa9 \
    header:#7aa89f
set -x FZF_DEFAULT_OPTS "--color="(string join , $_fzf_colors)


zoxide init fish | source
starship init fish | source
pyenv init - fish | source

set --universal nvm_default_version v24

# pyright: force the global (node) language server ahead of the pyenv shim.
# The shim can't resolve climatics' .python-version=3.14 and hard-fails there;
# ~/.claude/bin holds only pyright/pyright-langserver, so it shadows nothing else.
# Must run AFTER `pyenv init` above so it precedes ~/.pyenv/shims on PATH.
set -x PATH $HOME/.claude/bin $PATH
