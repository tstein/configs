#!/bin/zsh

# Key bindings.
bindkey -e
bindkey TAB expand-or-complete-prefix
bindkey '^[[Z' reverse-menu-complete    # shift-tab
bindkey '^R' history-incremental-pattern-search-backward  # understands globs
bindkey '^[[20~' tetris     # Press F9 to play.

case `get_prop OS` in
  'Linux')
    # Can't count on these keys to be consistent. This switch sets the following:
    #   <Delete>        :   delete-char
    #   <Home>          :   beginning-of-line
    #   <End>           :   end-of-line
    #   <PageUp>        :   insert-last-word
    #   <PageDown>      :   end-of-history
    #   ^<LeftArrow>    :   backward-word
    #   ^<RightArrow>   :   forward-word
    case "$TERM" in
      'alacritty')
        bindkey '^[[3~'     delete-char
        bindkey '^[[H'      beginning-of-line
        bindkey '^[[F'      end-of-line
        bindkey '^[[5~'     insert-last-word
        bindkey '^[[6~'     end-of-history
        bindkey '^[[1;5D'   backward-word
        bindkey '^[[1;5C'   forward-word
        ;;
      'xterm'*)
        bindkey '^[[3~'     delete-char
        bindkey '^[OH'      beginning-of-line
        bindkey '^[OF'      end-of-line
        bindkey '^[[5~'     insert-last-word
        bindkey '^[[6~'     end-of-history
        bindkey '^[[1;5D'   backward-word
        bindkey '^[[1;5C'   forward-word
        ;;
      'rxvt'*)
        bindkey '^[[3~'     delete-char
        bindkey '^[[7~'     beginning-of-line
        bindkey '^[[8~'     end-of-line
        bindkey '^[[5~'     insert-last-word
        bindkey '^[[6~'     end-of-history
        bindkey '^[Od'      backward-word
        bindkey '^[Oc'      forward-word
        ;;
      'screen'*|'tmux'*)
        bindkey '^[[3~'     delete-char
        bindkey '^[[1~'     beginning-of-line
        bindkey '^[[4~'     end-of-line
        bindkey '^[[5~'     insert-last-word
        bindkey '^[[6~'     end-of-history
        bindkey '^[[1;5D'   backward-word
        bindkey '^[O5D'     backward-word
        bindkey '^[OD'      backward-word
        bindkey '^[[1;5C'   forward-word
        bindkey '^[O5C'     forward-word
        bindkey '^[OC'      forward-word
        ;;
      'linux')
        bindkey '^[[3~'     delete-char
        bindkey '^[[1~'     beginning-of-line
        bindkey '^[[4~'     end-of-line
        bindkey '^[[5~'     insert-last-word
        bindkey '^[[6~'     end-of-history
        # mingetty doesn't distinguish between ^<LeftArrow> and <LeftArrow>.
        ;;
    esac
    ;;
  'Ossix')
    bindkey '[D'            backward-word       # option-left
    bindkey '[C'            forward-word        # option-right
    bindkey '^[[1;10D'      beginning-of-line   # shift-option-left
    bindkey '^[[1;10C'      end-of-line         # shift-option-right
    ;;
esac


# Magic space expansion.
# cause a space to expand to certain text given what's already on the line.
typeset -A abbreviations
abbreviations=(
'lame'              'lame -V 0 -q 0 -m j --replaygain-accurate --add-id3v2'
)
case `get_prop OS` in
  'Linux')
    abbreviations+=(
    'df'                'df -hT -x tmpfs -x devtmpfs --total'
    'lsblk'             'lsblk -o NAME,MODEL,TYPE,SIZE,PHY-SEC,MQ,RQ-SIZE,SCHED'
    'ps'                'ps axwwo user,pid,ppid,pcpu,cputime,nice,pmem,rss,lstart=START,stat,tname,command'
    )
    ;;
  'Ossix')
    abbreviations+=(
    'df'                'df -h'
    'ps'                'ps axwwo user,pid,ppid,pcpu,cputime,nice,pmem,rss,lstart=START,stat,command'
    )
    ;;
esac

magic-abbrev-expand() {
  local MATCH
  LBUFFER=${LBUFFER%%(#m)[_a-zA-Z0-9 ]#}
  LBUFFER+=${abbreviations[$MATCH]:-$MATCH}
  zle self-insert
}

no-magic-abbrev-expand() {
  LBUFFER+=' '
}

zle -N magic-abbrev-expand
zle -N no-magic-abbrev-expand
bindkey " " magic-abbrev-expand
bindkey "^x" no-magic-abbrev-expand
