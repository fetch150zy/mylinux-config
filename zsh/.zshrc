COLOR_SCHEME=dark
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="fetch150zy"

alias cls='clear'
# alias ls='lsd'
# alias ll='lsd -l'
# alias la='lsd -a'
# alias lla='lsd -la'
# alias lt='lsd --tree'

# mcfly (shell history)
alias shs='mcfly search'
eval "$(mcfly init zsh)"
export MCFLY_KEY_SCHEME=vim
export MCFLY_FUZZY=2
export MCFLY_RESULTS=50
export MCFLY_DELETE_WITHOUT_CONFIRM=true
export MCFLY_DISABLE_MENU=TRUE
export MCFLY_RESULTS_SORT=LAST_RUN
export MCFLY_PROMPT="# "

alias check='bat'
alias picture='display'
alias video='timg -g80x80'
alias disk_info='duf'
alias disk_usage='dust'

alias process='procs -t'
alias sys_info='gtop'
alias benchmark='hyperfine --warmup 3 --runs 100
                            --export-csv benchmark.csv \
                            --export-json benchmark.json \
                            --export-markdown benchmark.md \
                            > output'
alias dns='dog'
alias ping='gping'
alias backup='async'
alias search='rg'

# update automatically without asking
zstyle ':omz:update' mode auto      
# how often to auto-update (in days).
zstyle ':omz:update' frequency 13

# plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh



export MANPATH="/usr/local/man:$MANPATH"
export LANG=en_US.UTF-8


export GOPATH=$HOME/go
export GOROOT=/usr/lib/go
export GO111MODULE=on
[[ -s "/home/fetch150zy/.gvm/scripts/gvm" ]] && source "/home/fetch150zy/.gvm/scripts/gvm"

export PATH="${PATH}:/usr/local/cuda/bin"
export LD_LIBRARY="${LD_LIBRARY}:/usr/local/cuda/lib64"

eval $(thefuck --alias)

source /home/fetch150zy/.config/broot/launcher/bash/br
source /tools/Xilinx/Vivado/2022.1/settings64.sh
