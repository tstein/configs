# zsh options. {{{
# Each group corresponds to a heading in the zshoptions manpage.
# dir opts
setopt autocd autopushd pushd_silent

# completion opts
setopt autolist autoparamkeys autoparamslash hashlistall listambiguous listpacked listtypes

# expansion and globbing
setopt extended_glob glob glob_dots

# history opts
setopt share_history extended_history hist_ignore_space

# I/O
setopt aliases clobber correct hashcmds hashdirs ignoreeof rmstarsilent normstarwait

# job control
setopt autoresume notify

# prompting
setopt promptpercent

# scripts and functions
setopt cbases functionargzero localoptions multios

# ZLE
setopt nobeep zle

# emergency file ops
# Per zshmodules(1), this form only loads prefixed builtins, which avoids
# shadowing the more capable external versions.
zmodload -m -F zsh/files b:zf_\*
# This only loads the zstat builtin and does not shadow the more capable
# external stat.
zmodload -F zsh/stat b:zstat

zmodload zsh/sched
####################################### }}}

# Load the modular parts of this config. {{{
# Migrate from my made-up ~/.zsh to my less-made-up ~/.config/zsh.
if [ -d ~/.zsh ]; then
  if [ -d ~/.config/zsh ]; then
    print "~/.zsh exists, but so does ~/.config/zsh. Ignoring ~/.zsh."
  else
    mkdir -p ~/.config
    mv ~/.zsh ~/.config/zsh
    print "Migrated ~/.zsh to ~/.config/zsh."
  fi
fi

_user_funcs=~/.config/zsh/functions
if ! (($fpath[(Ie)$_user_funcs])); then
  fpath=($_user_funcs $fpath)
fi

if [ -d ~/.config/zsh/conf.d ]; then
  for zfile in ~/.config/zsh/conf.d/*.zsh; do
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
if [ `get_prop have_nvim` ]; then
  export EDITOR=nvim
else
  export EDITOR=vim
fi
export PAGER="less -FRX"

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
battery_cornmeter() {
  case `get_prop OS` in
    'Linux')
      BAT='/sys/class/power_supply/BAT1'
      LEVEL=$((`cat $BAT/capacity` * 1.0))
      grep -q '^Charging$' $BAT/status
      CHARGING=$?
      ;;
    'Ossix')
      PMSET=`pmset -g batt`
      LEVEL=`print $PMSET | perl -ne 'if (/(\d+)%/) { print $1; }'`
      print $PMSET | grep -q 'AC Power'
      CHARGING=$?
      ;;
  esac

  if [[ $CHARGING == 0 ]]; then
    if [ `get_prop unicode` ]; then
      CHRGCHR='⚡'
    else
      CHRGCHR='C'
    fi
  else
    CHRHCHR=''
  fi

  cornmeter $LEVEL 100 "$CHRGCHR" 95 30
}

quota_cornmeter() {
  local QUOTA_LEVEL=`cat "$QUOTA_FILE"`
  local QUOTA_LEVEL_TEXT="`printf %.0f $QUOTA_LEVEL` GB"
  if [[ $QUOTA_LEVEL -ge 9999 ]]; then
    # basically infinity
    QUOTA_LEVEL=$((4 * $QUOTA_CAP))
    QUOTA_LEVEL_TEXT="∞ GB"
  fi
  cornmeter $QUOTA_LEVEL $QUOTA_CAP $QUOTA_LEVEL_TEXT 50 20
}

# If we're in a repo, print some info. Intended for use in a prompt. {{{
# Updates the variable that contains VCS info.
update_rprompt_vcs_status() {
  if [ `get_prop have_git` ]; then
    GIT=`git_status`
  fi
  _RPROMPT_VCS="$GIT"
}

git_status() {
  local GITBRANCH=''
  local GITSTATUS=''
  local GITTXT='git'
  local TIMEOUTTXT='<slow>'
  if [ `get_prop unicode` ]; then
    GITTXT='±'
    TIMEOUTTXT='⌛'
  fi

  # This blocks the next prompt. If it takes a while just to check the branch,
  # bail out.
  if [ `get_prop have_timeout` ]; then
    GITBRANCH=`timeout .5s git symbolic-ref HEAD 2>/dev/null`
  else
    GITBRANCH=`git symbolic-ref HEAD 2>/dev/null`
  fi
  case $? in
    124)
      # we timed out while trying to determine if we are in a git repo
      print -n " $GITTXT:$TIMEOUTTXT"
      return
      ;;
    128)
      # we are not in a git repo
      return
      ;;
    0)
      # we are in a git repo
      print -n " $GITTXT:${GITBRANCH#refs/heads/}"
      if [ `get_prop have_timeout` ]; then
        GITSTATUS=`timeout .20s git status`
      else
        GITSTATUS=`git status`
      fi
      if [[ $? == 124 ]]; then
        # timeout
        print -n $TIMEOUTTXT
        return
      fi

      GITSTATUS=`print $GITSTATUS | grep -q "nothing to commit"`
      if [[ $? == 0 ]]; then
        # clean
        return
      else
        # dirty
        print -n "(*)"
        return
      fi
      ;;
  esac
}
# }}}

# When on a laptop, enable cornmeter.
update_rprompt() {
  local BOLD_ON BOLD_OFF DIR GIT COND_RETVAL BATTERY_METER QUOTA_METER
  BOLD_ON='%B'
  DIR=`print -P '%~'`
  COND_RETVAL='%(?..{%?})'

  if [ `get_prop have_battery` ]; then
    BATTERY_METER=`battery_cornmeter`
  fi
  if [[ $QUOTA_FILE && $QUOTA_CAP ]]; then
    QUOTA_METER=`quota_cornmeter`
  fi

  BOLD_OFF='%b'
  RPROMPT="$PR_CYAN$BOLD_ON"["$DIR$_RPROMPT_VCS"]"$COND_RETVAL"
  RPROMPT+="$BATTERY_METER$QUOTA_METER$BOLD_OFF"
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

# Enable highlighting if it's installed.
HI_FILE=/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
if [[ -e $HI_FILE ]]; then
  source $HI_FILE
fi

#TODO: Check if we are a login shell. This could hang a script without that.
if [ `get_prop have_keychain` ]; then
  keychain -Q -q ${ssh_key_list[@]}
  source ~/.keychain/${HOST}-sh
fi

# Disable STOP/START for terminal output.
stty -ixon
####################################### }}}

# ZSH IS GO
#######################################
