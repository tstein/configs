# Designed to be called on first run, as decided by the presence or absence of a
# ~/.zlocal.

get-comfy() {
  # If this function gets ^C'd, catch it and return so the rest of the zsh
  # config is sourced properly.
  trap 'trap 2; return 1' 2
  if [[ -f ~/.zlocal ]]; then
    print "You have a ~/.zlocal on this machine. If you really intended to run this function,"
    print "delete it and try again."
    return 1
  fi

  print "# vim: ft=zsh" >>~/.zlocal
  print >>~/.zlocal

  print "Looks like it's your first time here.\n"
  survey
  print
  print "What color would you like your prompt on this machine to be?"
  print -n "["
  print -n $T_RED"red"$T_NO_COLOR"|"
  print -n $T_GREEN"green"$T_NO_COLOR"|"
  print -n $T_BLUE"blue"$T_NO_COLOR"|"
  print -n $T_CYAN"cyan"$T_NO_COLOR"|"
  print -n $T_MAGENTA"magenta"$T_NO_COLOR"|"
  print -n $T_YELLOW"yellow"$T_NO_COLOR"|"
  print -n $T_WHITE"white"$T_NO_COLOR"|none]: "
  local CHOICE=""
  read CHOICE
  case "$CHOICE" in
    'none')
      print "Really? That's no fun. :/"
      ;&
    ('red'|'green'|'blue'|'cyan'|'magenta'|'yellow'|'white'))
      CHOICE=`echo $CHOICE | tr 'a-z' 'A-Z'`
      print "PR_COLOR=\$PR_$CHOICE" >>~/.zlocal
      ;;
    *)
      print "You get blue, wiseguy. Set PR_COLOR later if you want anything else."
      ;;
  esac

  print "Would you like an emoji or something in your left prompt?"
  print -n "Leave blank for the default [%]: "
  read CHOICE
  if [[ -v CHOICE ]]; then
    # add an extra space - a lot of terms seem to render emoji double-wide
    print "PR_CHAR=\"$CHOICE \"" >>~/.zlocal
  fi

  AUTO_MTMUX=""
  while [[ $AUTO_MTMUX != "y" && $AUTO_MTMUX != "n" ]]; do
    print -n "Would you like to automatically attach to your main tmux session? [yn] "
    read AUTO_MTMUX
  done
  if [[ $AUTO_MTMUX == "y" ]]; then
    cat >>~/.zlocal <<EOF

# auto-mtmux
# TMUX isn't passed by default, but TERM is. Check both to prevent nesting when
# sshing in from another tmux.
if [[ ! -v TMUX && \$TERM != tmux-* ]]; then
  ~/.local/bin/mtmux
fi
EOF
  fi

  print "Wrote those config changes into ~/.zlocal."
  trap 2
}

# do-nothing modeline so vims don't get unhappy about the one this outputs
# vim
