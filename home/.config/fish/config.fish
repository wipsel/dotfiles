# ~/.config/fish/config.fish

### ENVIRONMENT VARIABLES ###
set -x PATH $HOME/bin /usr/local/bin /usr/local/go/bin $HOME/go/bin $PATH
set -x GO111MODULE on
set -x GOPRIVATE gitlab.advancedclimate.nl
set -x TERM xterm-256color
set -g fish_greeting

### EDITOR BASED ON SSH CONNECTION ###
if test -n "$SSH_CONNECTION"
    set -x EDITOR nvim
else
    set -x EDITOR nvim
end

### PROMPT (Starship) ###
# Make sure starship is installed (https://starship.rs)
starship init fish | source

### ALIASES ###
alias activate "source .env/bin/activate"
alias ls "exa"
alias vim "nvim"
alias gst "git status"
alias bus "./.screenlayout/bus.sh"
alias thuis "./.screenlayout/thuis.sh"
alias tsserver "npx tsserver"

### CUSTOM FUNCTIONS ###
function rename
    set from $argv[1]
    set to $argv[2]
    for file in $argv[3..-1]
        perl -i -p -e "s{$from}{$to}g;" $file
        echo "Changing $from to $to in $file"
    end
end

### FZF SETUP ###
# Adjust the paths if you're on a different distro or installed fzf manually
if test -f /usr/share/fzf/key-bindings.fish
    source /usr/share/fzf/key-bindings.fish
end
if test -f /usr/share/fzf/completion.fish
    source /usr/share/fzf/completion.fish
end

set -x FZF_DEFAULT_OPTS '--color=fg:#dcd7ba,bg:#1e1f28,hl:#9cabca,fg+:#727169,bg+:#2a2a37,hl+:#7e9cd8,info:#7aa89f,prompt:#e46876,pointer:#957fb8,marker:#98bb6c,spinner:#938aa9,header:#7aa89f'

### ZOXIDE ###
# Make sure zoxide is installed: https://github.com/ajeetdsouza/zoxide
zoxide init fish | source

### PYENV SETUP ###
# Make sure pyenv is installed and accessible
set -x PYENV_ROOT $HOME/.pyenv
set -x PATH $PYENV_ROOT/bin $PATH

# Only load if interactive
status --is-interactive; and pyenv init - | source
pyenv virtualenv-init - | source

### NVM (via fisher plugin) ###
# Make sure you ran:
# fisher install jorgebucaran/nvm.fish
# Then:
# nvm install node
# nvm use node
