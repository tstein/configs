#!/bin/zsh

# Didn't-deserve-a-functions:
alias chomp="sed -e 's/^[[:space:]]*//' | sed -e 's/[[:space:]]*$//'"
alias dirty-bytes="grep Dirty /proc/meminfo | cut -d: -f2 | sed 's/B/Byte/' | qalc -t | head -n 3 | tail -n 1"
alias getip='curl ifconfig.me'
alias mirror-recursive='wget --mirror --adjust-extension --convert-links --page-requisites --span-hosts \
    --user-agent mozilla'
alias sudo='sudo '  # Enables alias, but not function, expansion on the next word.
alias watchfreq="watch 'cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq | sort -rn'"

# Keystroke-savers:
alias -- -='cd -'
alias absname='readlink -m'
alias dict='dict -d wn'
alias ffmpeg='ffmpeg -hide_banner'
alias ffprobe='ffprobe -hide_banner'
alias ncplayer='ncplayer -s scalehi'
alias no='yes n'
alias pdfcat='gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=out.pdf'
alias rezsh='source ~/.zshrc'
alias vimdir='nvim +Renamer '
if [[ `get_prop OS` == 'Linux' ]]; then
    alias open='xdg-open'
fi
# not an alias, but spiritually appropriate for this file
export FZF_DEFAULT_OPTS='--exact --multi --cycle --border --height=50% --reverse'

# Option-setters:
alias bc='bc -l'
alias dd='dd status=progress'
alias fortune='fortune -c'
alias getpwdfs='getfstype .'
alias grep='grep --color=auto'
alias less='less -FRX'

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
