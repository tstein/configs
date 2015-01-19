#!/bin/zsh

# Didn't-deserve-a-functions:
alias chrome-get-rss='
  CHROME_RSS=0
  for num in `ps axwwo rss,command | grep -P "(google-|)(chrome|chromium)" | grep -v grep | sed "s/^\s*//g" | cut -d " " -f 1`
  do
      CHROME_RSS=$(($num * 1 + $CHROME_RSS))
  done
  print $CHROME_RSS; unset CHROME_RSS'
alias getip='curl ifconfig.me'
alias sudo='sudo '  # Enables alias, but not function, expansion on the next word.

# Keystroke-savers:
alias -- -='cd -'
alias absname='readlink -m'
alias chrome='google-chrome'
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
