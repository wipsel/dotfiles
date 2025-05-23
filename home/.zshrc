# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:/usr/local/go/bin:/home/wipsel/go/bin:/home/wipsel/.local/bin:$PATH
export GO111MODULE=on
export GOPRIVATE=gitlab.advancedclimate.nl
export TERM=xterm-256color ssh



# Path to your oh-my-zsh installation.
export ZSH="/home/wipsel/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
#ZSH_THEME="robbyrussell"
ZSH_THEME="wipsel"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
#COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)
#plugins+=(zsh-vi-mode)

ZVM_VI_INSERT_ESCAPE_BINDKEY=jj

source $ZSH/oh-my-zsh.sh
source $HOME/.docker_env

#source /usr/share/autojump/autojump.zsh
#autoload -U compinit && compinit -u
# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

 #Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='nvim'
 else
   export EDITOR='nvim'
 fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
source /usr/share/fzf/completion.zsh && source /usr/share/fzf/key-bindings.zsh
function zvm_after_init() {
    source /usr/share/fzf/completion.zsh && source /usr/share/fzf/key-bindings.zsh
}

export FZF_DEFAULT_OPTS='--color=fg:#dcd7ba,bg:#1e1f28,hl:#9cabca,fg+:#727169,bg+:#2a2a37,hl+:#7e9cd8,info:#7aa89f,prompt:#e46876,pointer:#957fb8,marker:#98bb6c,spinner:#938aa9,header:#7aa89f'

source "$HOME/.homesick/repos/homeshick/homeshick.sh"
# source environment variables
# Example aliases
# alias zshconfig="mate ~/.zshrc"
alias activate="source .env/bin/activate"
alias ls="exa"
alias bus="./.screenlayout/bus.sh"
alias thuis="./.screenlayout/thuis.sh"
alias tsserver="npx tsserver"

export UV_AUTO_VENV=1
# alias pnpm="npx pnpm"
# alias ohmyzsh="mate ~/.oh-my-zsh"
export PYENV_ROOT="$HOME/.pyenv"

#eval "$(ssh-agent -s)" > /dev/null
#ssh-add ~/.ssh/github > /dev/null



export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# colorfol manpager
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

eval "$(pyenv virtualenv-init -)"
eval "$(zoxide init zsh)"

vim () {
  if [[ -f uv.lock ]]; then
    command uv run nvim "$@"
  else
    command nvim "$@"
  fi
}


# find and replace strings in all files recursively
rename () {
    from=$1 
    shift
    to=$1 
    shift
    for file in $*
    do
            perl -i -p -e "s{$from}{$to}g;" $file
            echo "Changing $from to $to in $file"
    done
}
