export PATH="$PATH:$HOME/go/bin:$HOME/.cargo/bin:$HOME/.local/bin"
eval "$(starship init bash)"

eval "$(zoxide init bash --cmd cd)"

source $HOME/.config/fzf/fzf-bash-completion.sh

eval "$(mise activate bash)"

bind -x '"\t": fzf_bash_completion'

if [ -n "$SSH_TTY" ]; then
    fastfetch
fi
