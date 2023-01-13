# Designed to be called on first run, as decided by the presence or absence of a
# .zlocal.

get-comfy() {
    # If this function gets ^C'd, we want to catch it and return so the rest of
    # this file is sourced properly.
    trap 'trap 2; return 1' 2
    if [[ -f ~/.zlocal ]]; then
        print -l "You have a .zlocal on this machine. If you really intended to run this function,\n
        delete it manually and try again."
        return 1
    fi

    survey | prefix '# ' >>~/.zlocal
    print >>~/.zlocal

    print -l "Looks like it's your first time here.\n"
    survey
    print -l "\nWhat color would you like your prompt on this machine to be?"
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
            print -l "Really? That's no fun. :/"
        ;&
        ('red'|'green'|'blue'|'cyan'|'magenta'|'yellow'|'white'))
            CHOICE=`echo $CHOICE | tr 'a-z' 'A-Z'`
            print -l "PR_COLOR=\$PR_$CHOICE\n" >>~/.zlocal
        ;;
        *)
            print -l "You get blue, wiseguy. Set PR_COLOR later if you want anything else."
        ;;
    esac
    print >>~/.zlocal
    AUTO_MTMUX=""
    while [[ $AUTO_MTMUX != "y" && $AUTO_MTMUX != "n" ]]; do
      print -n "Would you like to automatically attach to your main tmux session? [yn] "
      read AUTO_MTMUX
    done
    if [[ $AUTO_MTMUX == "y" ]]; then
      print "# auto-mtmux" >>.zlocal
      print "if [[ ! -v TMUX ]]; then" >>.zlocal
      print "  ~/.local/bin/mtmux" >>.zlocal
      print "fi" >>.zlocal
      print >>~/.zlocal
    fi
    print "# vim: ft=zsh" >>~/.zlocal

    print -l 'All the above information has been saved to ~/.zlocal. Happy zshing!'
    trap 2
}

# do-nothing modeline so vims don't get unhappy about the one this outputs
# vim
