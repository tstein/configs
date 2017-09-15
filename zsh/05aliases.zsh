#!/bin/zsh

# Didn't-deserve-a-functions:
alias getip='curl ifconfig.me'
alias sudo='sudo '  # Enables alias, but not function, expansion on the next word.

# Keystroke-savers:
alias -- -='cd -'
alias absname='readlink -m'
alias dict='dict -d wn'
alias no='yes n'
if [[ `get_prop OS` == 'Linux' ]]; then
    alias open='xdg-open'
fi
alias rezsh='source ~/.zshrc'

# Option-setters:
alias bc='bc -l'
alias fortune='fortune -c'
alias getpwdfs='getfstype .'
alias grep='grep --color=auto'
alias less="$PAGER"

case `get_prop OS` in
  'Linux')
    alias ls='ls -F --color=auto'
    ;;
  'Ossix')
    alias ls='ls -FG'
    ;;
esac

# Fool-me-twice-preventers:
alias rm='rm -i'
