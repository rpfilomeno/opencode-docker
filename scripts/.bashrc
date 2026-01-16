export PATH="$PATH:$HOME/go/bin"

eval "$(starship init bash)"

eval "$(zoxide init bash --cmd cd)"

source $HOME/.config/fzf/fzf-bash-completion.sh

bind -x '"\t": fzf_bash_completion'

