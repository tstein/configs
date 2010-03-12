# .zshrc configured for halberd
#######################################

#######################################
# setopt lines - sections correspond to zshoptions
# dir opts
setopt autocd chaselinks

# completion opts
setopt autolist autoparamkeys autoparamslash hashlistall listambiguous listpacked listtypes

# expansion and globbing
setopt extended_glob glob glob_dots

# history opts
setopt extendedhistory

# I/O
setopt aliases clobber correct hashcmds hashdirs ignoreeof normstarsilent normstarwait

# job control
setopt autoresume notify

# prompting
setopt promptpercent

# scripts and functions
setopt cbases functionargzero localoptions multios

# ZLE
setopt nobeep zle
#######################################



#######################################
# The following lines were added by compinstall
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' matcher-list ''
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:kill:*:processes' command 'ps -axco pid,user,command'
zstyle :compinstall filename '/home/ted/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# autoload various functions provided with zsh
autoload -Uz sticky-note url-quote-magic zcalc zed zmv
zle -N self-insert url-quote-magic

# set up colors for prompt
autoload -U colors
colors
for color in RED GREEN BLUE YELLOW MAGENTA CYAN WHITE BLACK; do
    eval PR_$color='%{$fg[${(L)color}]%}'
done
PR_NO_COLOR="%{$terminfo[sgr0]%}"

# enable tetris - don't forget to bind it
autoload -Uz tetris
zle -N tetris
#######################################



#######################################
# custom key bindings
bindkey -e
bindkey TAB expand-or-complete-prefix
bindkey '' delete-word
bindkey '^J' backward-delete-word
bindkey '[1;5D' backward-word # Ctrl <-
bindkey '[1;5C' forward-word  # Ctrl ->

# can't count on these keys to be consistent
case "$TERM" in
    'xterm')
    bindkey '[H' beginning-of-line
    bindkey 'OH' beginning-of-line
    bindkey '[F' end-of-line
    bindkey 'OF' end-of-line
    bindkey '[3~' delete-char
    bindkey '[6~' end-of-history
    bindkey '[5~' insert-last-word
    ;;
    'xterm*')
    bindkey 'OH' beginning-of-line
    bindkey 'OF' end-of-line
    bindkey '[3~' delete-char
    bindkey '[6~' end-of-history
    bindkey '[5~' insert-last-word
    ;;
    'rxvt-unicode')
    bindkey '^[[7~' beginning-of-line
    bindkey '[8~' end-of-line
    bindkey '[3~' delete-char
    bindkey '[6~' end-of-history
    bindkey '[5~' insert-last-word
    ;;
    'screen')
    bindkey '[1~' beginning-of-line
    bindkey '[4~' end-of-line
    bindkey '[3~' delete-char
    bindkey '[6~' end-of-history
    bindkey '[5~' insert-last-word
    ;;
    'linux')
    bindkey '[1~' beginning-of-line
    bindkey '[4~' end-of-line
    bindkey '[3~' delete-char
    bindkey '[6~' end-of-history
    bindkey '[5~' insert-last-word
    ;;
esac

bindkey '[20~' tetris # F9
#######################################



#######################################
# command customizations
# aliases
alias bc='bc -l'
alias cep='call-embedded-perl'
alias emacs='emacs -nw'
alias fortune='fortune -c'
alias getip='ifconfig | perl -ne "if (/inet addr:/) { s/\s+inet addr://; s/ .*\n//; print $F; last; }"'
alias grep='grep --color=auto'
alias ls='ls --color=auto -F'
alias open='xdg-open'
alias rm='rm -i'    # someday, I hope to earn the right to remove this line
alias units='units --verbose'

# command functions
oh() {
    echo "oh $@"
}

update-rc() {
    update-zshrc
    update-vimrc
}

update-zshrc() {
    rsync -azve "ssh -p54848" ted@halberd.dyndns.org:~/.zshrc ~/.zshrc && source ~/.zshrc
}

update-vimrc() {
    rsync -azve "ssh -p54848" ted@halberd.dyndns.org:~/.vimrc ~/.vimrc
}

call-embedded-perl() {
    if [[ "$1" == "debug" ]]; then
        DEBUG_CEP="TRUE"
        shift
    fi
    
    if [[ $ARGC -eq 0 ]]; then
        print -l "Which script would you like to run?"
        return 0;
    fi
    SCRIPT="$1"
    shift
    
    if [[ "$DEBUG_CEP" == "TRUE" ]]; then
        DEBUG_CEP="FALSE"
        perl -ne "print $F if s/#$SCRIPT#//" ~/.zshrc
    else
        perl -ne "print $F if s/#$SCRIPT#//" ~/.zshrc | perl -w
    fi
}

get-comfy() {
    trap 'trap 2; return 1' 2
    if [[ -f ~/.zlocal ]]; then
        print -l "You have a .zlocal on this machine. If you really intended to run this function, delete it manually and try again."
        return 1
    fi
    print -l "\nLooks like it's your first time here.\n"
    DATE=`date -R`
    print -l ".zlocal for "`hostname`" created on $DATE" >> ~/.zlocal
    print -l "configuration:\n" >> ~/.zlocal
    call-embedded-perl localinfo | tee -a ~/.zlocal
    sed -i 's/.*/# &/' ~/.zlocal
    print >> ~/.zlocal
    print -l "\nWhat color would you like your prompt on this machine to be? Pick one."
    print -n "[red|green|blue|cyan|magenta|yellow|white|black]: "
    read CHOICE
    case "$CHOICE" in
        'red')
        print -l 'PR_COLOR=$PR_RED\n' >> ~/.zlocal
        ;;
        'green')
        print -l 'PR_COLOR=$PR_GREEN\n' >> ~/.zlocal
        ;;
        'blue')
        print -l 'PR_COLOR=$PR_BLUE\n' >> ~/.zlocal
        ;;
        'cyan')
        print -l 'PR_COLOR=$PR_CYAN\n' >> ~/.zlocal
        ;;
        'magenta')
        print -l 'PR_COLOR=$PR_MAGENTA\n' >> ~/.zlocal
        ;;
        'yellow')
        print -l 'PR_COLOR=$PR_YELLOW\n' >> ~/.zlocal
        ;;
        'white')
        print -l 'PR_COLOR=$PR_WHITE\n' >> ~/.zlocal
        ;;
        'black')
        print -l "Really? If you say so..."
        print -l 'PR_COLOR=$PR_BLACK\n' >> ~/.zlocal
        ;;
        *)
        print -l "You get blue. Set PR_COLOR in .zlocal later if you want anything else."
        ;;
    esac
    print -l
    trap 2
}

# interface-printing functions
drawCornMeter() {
    WIDTH=$1
    LEVEL=`acpi -b | perl -ne '/(\d{1,3}\%)/; $LVL = $1; $LVL =~ s/\%//; print $LVL;'`
    CHARGING=`acpi -a | perl -ne '/on-line/; print $1'`
    print -n $PR_WHITE"["
    LEVEL=$(($LEVEL * 1.0))
    if (($LEVEL <= 30.0)); then
        print -n $PR_RED
    else
        print -n $PR_YELLOW
    fi
    if (($LEVEL >= 98.0)); then
        print -n $PR_WHITE
    fi
    for (( i = 0; i < $WIDTH; i++ ))
    do
        if (($(($i + 1)) == $WIDTH)); then
            if [ `acpi -a | grep -o on-line` ]; then
                print -n "C"
                continue
            fi
        fi

        LEVEL=$(($LEVEL - (100.0 / $WIDTH))) 
        if (($LEVEL >= 0.0)); then
            if (($LEVEL <= 2.5)); then
                print -n "-"
            else
                print -n "="
            fi
        else
            print -n " "
        fi
    done
    print -n $PR_WHITE"]"
}
#######################################



#######################################
# embedded Perl scripts
#
# To create a new script, write it here, with each line prefixed with #NAME#. It will be callable
# with `call-embedded-perl NAME`.

#localinfo#
#localinfo#  # TODO: switch from grep -P to perl proper.
#localinfo#  $sysinfo = "";
#localinfo#  $buffer = `uname -s`;
#localinfo#  chomp($buffer);
#localinfo#      $sysinfo .= "Operating system:      $buffer\n";
#localinfo#  if (-e '/etc/issue') {
#localinfo#      $buffer = `head -n 1 /etc/issue`;
#localinfo#      $buffer =~ s/\s*\\\S+//g;
#localinfo#      chomp($buffer);
#localinfo#      $sysinfo .= "Distro/release:        $buffer\n";
#localinfo#  }
#localinfo#  if (-e '/proc/cpuinfo') {
#localinfo#      $buffer = `grep -P '(?:model name|cpu\\s+:)' /proc/cpuinfo | head -n 1`;
#localinfo#      $buffer =~ s/^(?:model name|cpu)\s*:\s*(.+)/$1/;
#localinfo#      $buffer =~ s/\((?:R|TM)\)//g;
#localinfo#      $buffer =~ s/CPU//;
#localinfo#      $buffer =~ s/\s{2,}/ /g;
#localinfo#      $buffer =~ s/[@\s]*[\d\.]+\s?[GM]Hz$//;
#localinfo#      chomp($buffer);
#localinfo#      $sysinfo .= "Processor:             $buffer\n";
#localinfo#      $buffer = `grep -P '(cpu MHz|clock)' /proc/cpuinfo | head -n 1`;
#localinfo#      $buffer =~ s/^(?:cpu MHz|clock)\s*:\s*(\d+).*/$1/;
#localinfo#      $buffer =~ s/MHz//;
#localinfo#      chomp($buffer);
#localinfo#      $sysinfo .= "Clock speed:           $buffer MHz\n";
#localinfo#      $buffer = `grep 'processor' /proc/cpuinfo | tail -n 1`;
#localinfo#      $buffer =~ s/^processor\s*:\s*(\d+)\s*\n[.\n]*/$1/;
#localinfo#      $buffer = $buffer + 1;
#localinfo#      $sysinfo .= "Count:                 $buffer\n";
#localinfo#  }
#localinfo#  if (-e '/proc/meminfo') {
#localinfo#      $buffer = `grep 'MemTotal' /proc/meminfo`;
#localinfo#      $buffer =~ s/^MemTotal:\s+(\d+).*$/$1/;
#localinfo#      $buffer = int($buffer / 1024);
#localinfo#      $sysinfo .= "Memory:                $buffer MB\n";
#localinfo#      $buffer = `grep 'SwapTotal' /proc/meminfo`;
#localinfo#      $buffer =~ s/^SwapTotal:\s+(\d+).*$/$1/;
#localinfo#      $buffer = int($buffer / 1024);
#localinfo#      $sysinfo .= "Swap:                  $buffer MB\n";
#localinfo#  }
#localinfo#  print $sysinfo;

#######################################



#######################################
# space expansion - cause a space to expand to certain text given what's already on the line
typeset -Ag abbreviations
abbreviations=(
    "ps"                "ps axwwo user,pid,ppid,pcpu,cputime,nice,pmem,rss,lstart=START,stat,tname,command"
    "sudo yum remove"   "sudo yum remove --remove-leaves"
)

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
bindkey "^x " no-magic-abbrev-expand
#######################################



#######################################
# shell configuration
# history-related variables
HISTFILE=~/.zhistfile
HISTSIZE=1000
SAVEHIST=1000000

#if [ `whence vim` ]; then
#    EDITOR='vim'
#    if [ `whence vimpager` ]; then
#        export PAGER="vimpager"
#    fi
#fi

# better to accidentally deny access than grant it
umask 077

# test for laptoppiness - $AM_LAPTOP will be true if there are batteries detected by acpi
AM_LAPTOP=`whence acpi`
if [ $AM_LAPTOP ]; then
    AM_LAPTOP=`acpi -b`
fi

# define how wide the RPROMPT battery meter should be
# this should really be dynamic
BATT_METER_WIDTH=20
#######################################



#######################################
# .zlocal is a file of my creation - contains site-specific anything so I don't have to modify this
# file for every machine.
# if needed, default values go first so that the source call overwrites them.
PR_COLOR=$PR_BLUE
if test ! -e ~/.zlocal; then
    get-comfy
fi
if test -f ~/.zlocal; then
    source ~/.zlocal
fi
#######################################



#######################################
# finally, let's set up our interface
# prompt lines
PROMPT=$PR_COLOR'%B[%n@%m %D{%H:%M}]\%#%b '
PROMPT2=$PR_GREEN'%B%_>%b '
RPROMPT=$PR_CYAN'%B[%~]%(?..{%?})%b'
SPROMPT=$PR_MAGENTA'zsh: correct '%R' to '%r'? '$PR_NO_COLOR

# precmd is executed before returning a prompt
# preexec is executed before running any command
# for $TERMs known to support it, use the title to give
#     who you are, where you're logged in, on what tty, and, if applicable, what you are currently running
case "$TERM" in
    xterm|xterm*|screen)
    if [ $AM_LAPTOP ]; then
        precmd() {
            print -Pn "\e]0;%(!.--==.)%n@%m%(!.==--.) (%y)\a"
            RPROMPT=$PR_CYAN'%B[%~]%(?..{%?})'`drawCornMeter $BATT_METER_WIDTH`'%b'
        }
    else
        precmd() {
            print -Pn "\e]0;%(!.--==.)%n@%m%(!.==--.) (%y)\a"
        }
    fi

    preexec() {
        print -Pn "\e]0;%(!.--==.)%n@%m%(!.==--.) <%30>...>$1%<<> (%y)\a"
    }
    ;;
esac
# ZSH IS GO
#######################################

