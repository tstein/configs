# .zshrc configured for halberd
#######################################

# zsh options. {{{
# Each group corresponds to a heading in the zshoptions manpage.
# dir opts
setopt autocd autopushd pushd_silent

# completion opts
setopt autolist autoparamkeys autoparamslash hashlistall listambiguous listpacked listtypes

# expansion and globbing
setopt extended_glob glob glob_dots

# history opts
setopt extendedhistory hist_ignore_space

# I/O
setopt aliases clobber correct hashcmds hashdirs ignoreeof rmstarsilent normstarwait

# job control
setopt autoresume notify

# prompting
setopt promptpercent

# scripts and functions
setopt cbases functionargzero localoptions multios

# shell emulation
setopt ksh_arrays

# ZLE
setopt nobeep zle
####################################### }}}

# Get the lay of the land and setup __prop {{{
# There are many properties of a system that influence what's appropriate in
# that environment. Before we do anything else, get the lay of the land and save
# it in an associative array. Intentionally left global.
typeset -A __prop
set_prop() { __prop[$1]=$2 }
get_prop() { print ${__prop[$1]} }

# Text encoding?
local ENCODING=`print -n $LANG | grep -oe '[^.]*$'`
# Mangle this a bit to deal with platform differences.
ENCODING=`print -n $ENCODING | tr '[a-z]' '[A-Z]' | tr -d -`
if [ ! $ENCODING ]; then
    ENCODING='UNKNOWN'
fi
set_prop encoding $ENCODING
if [[ `get_prop encoding` == 'UTF8' ]]; then
    set_prop unicode yes
fi

# Operating system?
case `uname -s` in
  'Linux')
    set_prop OS Linux
    ;;
  'Darwin')
    set_prop OS Ossix
    ;;
esac

# Installed programs?
for i in acpi keychain git hg; do
  if [ `whence $i` ]; then
    set_prop "have_$i" yes
  fi
done

# Laptop? (i.e., Can we access laptop-specific power info?)
case `get_prop OS` in
  'Linux')
    if [ `get_prop have_acpi` ]; then
      if [ "`acpi -b 2>/dev/null`" ]; then
        set_prop have_battery yes
      fi
    fi
    ;;
  'Ossix')
    if [ "`system_profiler SPHardwareDataType | grep 'MacBook'`" ]; then
      set_prop have_battery yes
    fi
    ;;
esac

####################################### }}}

# Set up colors. {{{
autoload -U colors; colors
for c in RED GREEN BLUE YELLOW MAGENTA CYAN WHITE BLACK; do
  eval T_$c='${fg[${(L)c}]}'
  eval PR_$c='%{$T_'$c'%}'
done
local T_NO_COLOR="${reset_color}"
local PR_NO_COLOR="%{$T_NO_COLOR%}"
####################################### }}}

# Command functions. {{{
# Above shell configuration because that needs get-comfy.
getfstype() {
    local DIR=$1
    if [ ! "$DIR" ]; then; return; fi
    # zsh lacks a do while, so I went with an explicit break from an infinite
    # loop. This will terminate as long as your cwd is of finite length.
    while (true); do
        local FS=`mount | grep " $DIR " | sed 's/.*type //' | sed 's/ .*//'`
        if [ "$FS" ]; then
            print $FS
            break
        fi
        if [[ "$DIR" == '/' ]]; then
            break
        fi
        DIR=`dirname $DIR`
    done
}

prefix() {
    local PREFIX=$1
    if [ ! "$PREFIX" ]; then
      echo "Usage: prefix str [args]"
      echo "  Prepend string to each line read and print it. args are passed to cat."
      return 1;
    fi
    shift
    cat $@ | sed "s/^/$PREFIX/"
}

# Designed to be called on first run, as decided by the presence or absence of a .zlocal.
get-comfy() {
    # If this function gets ^C'd, we want to catch it and return so the rest of
    # this file is sourced properly.
    trap 'trap 2; return 1' 2
    if [[ -f ~/.zlocal ]]; then
        print -l "You have a .zlocal on this machine. If you really intended to run this function,\n
        delete it manually and try again."
        return 1
    fi

    survey | prefix '# ' >> ~/.zlocal
    print >> ~/.zlocal

    print -l "Looks like it's your first time here.\n"
    survey
    print -l "\nWhat color would you like your prompt on this machine to be? Pick one."
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
            print -l "PR_COLOR=\$PR_$CHOICE\n" >> ~/.zlocal
        ;;
        *)
            print -l "You get blue, wiseguy. Set PR_COLOR later if you want anything else."
        ;;
    esac
    print -l 'All the above information has been saved to ~/.zlocal. Happy zshing!'
    trap 2
}
####################################### }}}

# Shell configuration. {{{
umask 022
HISTFILE=~/.zhistfile
HISTSIZE=5000
SAVEHIST=1000000
WORDCHARS="${WORDCHARS:s#/#}" # consider / as a word separator

# default programs
export EDITOR=vim
export PAGER="less -FRX"

# How wide the RPROMPT battery meter should be - for automatic width, set this to 0.
BATT_METER_WIDTH=0

# .zlocal is a file of my creation - contains site-specific anything so I don't have to modify this
# file for every machine. If needed, default values go first so that the source call overwrites
# them.
PR_COLOR=$PR_BLUE
PR_CHAR='%#'    # uid == 0 ? '%' : '#'
ssh_key_list=()
# Save these values so we can tell if they've been changed by zlocal.
typeset -A old_vals
old_vals+=("PROMPT" $PROMPT)
if test ! -e ~/.zlocal; then
  get-comfy
fi
if test -f ~/.zlocal; then
  source ~/.zlocal
fi
####################################### }}}

# Line editor configuration. {{{
# The following lines were added by compinstall a very long time ago.
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' matcher-list ''
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:kill:*:processes' command 'ps -axco pid,user,command'
zstyle :compinstall filename '/home/ted/.zshrc'
autoload -U compinit; compinit

# autoload functions provided with zsh
autoload -U is-at-least
if is-at-least "4.2.0"; then
    autoload -U url-quote-magic zmv
    zle -N self-insert url-quote-magic
fi

# enable tetris - don't forget to bind it
autoload -U tetris
zle -N tetris
####################################### }}}

# Interface functions. {{{
# cornmeter is a visual battery meter meant for a prompt. {{{
# This function spits out the meter as it should appear at call time.
drawCornMeter() {
  for var in WIDTH STEP LEVEL CHARGING SPPOWER CHARGE CAPACITY CHRGCHR; do
    eval local $var=""
  done
  CHRGCHR='C'
  if [ `get_prop unicode` ]; then
    CHRGCHR='⚡'
  fi
  WIDTH=$1
  STEP=$((100.0 / $WIDTH))
  case `get_prop OS` in
    'Linux')
      # acpi -b => "Battery 0: 22%"
      LEVEL=`acpi -b | cut -d ' ' -f 3 | tr -d '%'`
      LEVEL=$(($LEVEL * 1.0))
      CHARGING=`acpi -a | grep on-line`
      ;;
    'Ossix')
      PMSET=`pmset -g batt`
      LEVEL=`print $PMSET | perl -ne 'if (/(\d+)%/) { print $1; }'`
      CHARGING=`print $PMSET | grep 'AC Power'`
      ;;
  esac

  print -n $PR_WHITE"["
  if (($LEVEL <= 30.0)); then
    print -n $PR_RED
  else
    print -n $PR_YELLOW
  fi
  if (($LEVEL >= 95.0)); then
    print -n $PR_WHITE
  fi
  for (( i = 0; i < $WIDTH; i++ ))
  do
    if (($(($i + 1)) == $WIDTH)); then
      if [ "$CHARGING" ]; then
        print -n $CHRGCHR
        continue
      fi
    fi

    if (($LEVEL >= 0.0)); then
      if (($LEVEL <= $(($STEP / 2.0)))); then
        print -n "\-"
      else
        print -n "="
      fi
    else
      print -n " "
    fi
    LEVEL=$(($LEVEL - $STEP))
  done
  print -n $PR_WHITE"]"
} # }}}

# If we're in a repo, print some info. Intended for use in a prompt. {{{
# Updates the variable that contains VCS info. It's a bit slow to do this in
# precmd, so this goes in chpwd_functions.
update_rprompt_vcs_status() {
  if [ `get_prop have_git` ]; then
    GIT=`git_status`
  fi

  if [ `get_prop have_hg` ]; then
    HG=`hg_status`
  fi
  _RPROMPT_VCS="$GIT$HG"
}

git_status() {
  local GITBRANCH=''
  local GITTXT='git'
  if [ `get_prop unicode` ]; then
    GITTXT='±'
  fi
  git status &> /dev/null
  if (( $? != 128 )); then
    GITBRANCH=$(git symbolic-ref HEAD 2>/dev/null)
    print -n " $GITTXT:${GITBRANCH#refs/heads/}"
    if [ ! "`git status | grep \"nothing to commit\"`" ]; then
      print -n "(*)"
    fi
  fi
}

hg_status() {
  local HGTXT='hg'
  if [ `get_prop unicode` ]; then
    HGTXT='☿'
  fi
  hg status &> /dev/null
  if (( $? != 255 )); then
    print -n " $HGTXT:"
    print -n `hg summary | perl -ne 'if (/^branch: (.*)$/) { print $1; }'`
    if [ ! "`hg summary | grep clean`" ]; then
      print -n "(*)"
    fi
  fi
}
# }}}

# When on a laptop, enable cornmeter.
update_rprompt() {
  local BOLD_ON BOLD_OFF DIR GIT HG COND_RETVAL CORNMETER
  BOLD_ON='%B'
  DIR=`print -P '%~'`
  COND_RETVAL='%(?..{%?})'

  if [ `get_prop have_battery` ]; then
    if (( $BATT_METER_WIDTH > 0 )); then
      CORNMETER=`drawCornMeter $BATT_METER_WIDTH`
    else
      CORNMETER=`drawCornMeter $(($COLUMNS / 10))`
    fi
  fi

  BOLD_OFF='%b'
  RPROMPT="$PR_CYAN$BOLD_ON"["$DIR$_RPROMPT_VCS"]"$COND_RETVAL$CORNMETER$BOLD_OFF"
}

# For terms known to support it, print some info to the terminal title.
case "$TERM" in
  xterm*|screen*)
    precmd_update_title() {
      print -Pn "\e]0;%(!.--==.)%n@%m%(!.==--.) (%y)\a"
    }
    preexec_update_title() {
      print -Pn "\e]0;%(!.--==.)%n@%m%(!.==--.) <%30>...>$1%<<> (%y)\a"
    }
  ;;
esac
####################################### }}}

# Set up the interface. {{{
if [[ "$PROMPT" == "${old_vals[PROMPT]}" ]]; then
  PROMPT=$PR_COLOR"%B[%n@%m %D{%H:%M}]$PR_CHAR%b "
fi
PROMPT2=$PR_GREEN'%B%_>%b '
update_rprompt_vcs_status   # update_rprompt will automatically do the rest.
SPROMPT=$PR_MAGENTA'zsh: correct '%R' to '%r'? '$PR_NO_COLOR
unset old_vals

precmd_functions=(precmd_update_title update_rprompt_vcs_status update_rprompt)
preexec_functions=(preexec_update_title)

# Automatically time long commands.
REPORTTIME=10

#TODO: Check if we are a login shell. This could hang a script without that.
if [ `get_prop have_keychain` ]; then
  keychain -Q -q $ssh_key_list
  source ~/.keychain/${HOST}-sh
fi

# Disable STOP/START for terminal output.
stty -ixon
####################################### }}}

# Source additional configuration. {{{
if [ -d ~/.zsh ]; then
  for zfile in `ls ~/.zsh/*.zsh`; do
    source $zfile
  done
fi
####################################### }}}
# ZSH IS GO
#######################################
# vim:filetype=zsh foldmethod=marker autoindent expandtab shiftwidth=2
# Local variables:
# mode: sh
# End:
