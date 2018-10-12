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

# Load the modular parts. {{{
if [ -d ~/.zsh ]; then
  for zfile in `ls ~/.zsh/*.zsh`; do
    source $zfile
  done
fi
####################################### }}}

# Set up colors. {{{
autoload -U colors; colors
for c in RED GREEN BLUE YELLOW MAGENTA CYAN WHITE BLACK; do
  eval T_$c='${fg[${(L)c}]}'
  eval PR_$c='%{$T_'$c'%}'
done
T_NO_COLOR="${reset_color}"
PR_NO_COLOR="%{$T_NO_COLOR%}"
####################################### }}}

# Command functions. {{{
getfstype() {
    local DIR=`absname $1`
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

####################################### }}}

# Shell configuration. {{{
umask 022
HISTFILE=~/.zhistfile
HISTSIZE=5000
SAVEHIST=1000000
WORDCHARS="${WORDCHARS:s#/#}"

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
old_vals["PROMPT"]=$PROMPT
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
if [[ "$PROMPT" == "${old_vals["PROMPT"]}" ]]; then
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

# ZSH IS GO
#######################################
# vim:filetype=zsh foldmethod=marker autoindent expandtab shiftwidth=2
# Local variables:
# mode: sh
# End:
