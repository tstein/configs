# .zshrc configured for halberd
#######################################

# Shell configuration. {{{
# Set up colors for prompts. This must be done before zlocal gets sourced.
autoload -U colors
colors
for color in RED GREEN BLUE YELLOW MAGENTA CYAN WHITE BLACK; do
    eval local PR_$color='%{$fg[${(L)color}]%}'
done
local PR_NO_COLOR="%{$terminfo[sgr0]%}"

# zsh vars
WORDCHARS="${WORDCHARS:s#/#}" # consider / as a word separator

# history-related variables
HISTFILE=~/.zhistfile
HISTSIZE=5000
SAVEHIST=1000000

# default programs
export EDITOR=vim
export PAGER="less -FRX"

# How wide the RPROMPT battery meter should be - for automatic width, set this to 0.
BATT_METER_WIDTH=0

# better to accidentally deny access than grant it
umask 077

# .zlocal is a file of my creation - contains site-specific anything so I don't have to modify this
# file for every machine. If needed, default values go first so that the source call overwrites
# them.
PR_COLOR=$PR_BLUE
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

export PATH=~/bin:$PATH
####################################### }}}



# Properties: __prop {{{
# There are many properties of a system that influence what's appropriate in
# that environment. Before we do anything else, get the lay of the land and save
# it in an associative array. Intentionally left global.
typeset -A __prop
set_prop() { __prop+=($1 $2) }
get_prop() { print $__prop[$1] }

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
                set_prop am_laptop yes
            fi
        fi
    ;;
    'Ossix')
        if [ "`system_profiler SPHardwareDataType | grep 'MacBook'`" ]; then
            set_prop am_laptop yes
        fi
    ;;
esac

####################################### }}}



# zsh options. Each group corresponds to a heading in the zshoptions manpage. {{{
# dir opts
setopt autocd autopushd chaselinks pushd_silent

# completion opts
setopt autolist autoparamkeys autoparamslash hashlistall listambiguous listpacked listtypes

# expansion and globbing
setopt extended_glob glob glob_dots

# history opts
setopt extendedhistory

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
####################################### }}}



# zle configuration. {{{
# The following lines were added by compinstall a very long time ago.
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' matcher-list ''
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:kill:*:processes' command 'ps -axco pid,user,command'
zstyle :compinstall filename '/home/ted/.zshrc'

autoload -U compinit
compinit
# End of lines added by compinstall

# autoload various functions provided with zsh
autoload -U is-at-least
if is-at-least "4.2.0"; then
    autoload -U sticky-note url-quote-magic zcalc zed zmv
    zle -N self-insert url-quote-magic
fi

# enable tetris - don't forget to bind it
autoload -U tetris
zle -N tetris
####################################### }}}



# Key bindings. {{{
bindkey -e
bindkey TAB expand-or-complete-prefix
bindkey '^K' delete-word
bindkey '^J' backward-delete-word
bindkey '[20~' tetris     # Press F9 to play.

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
            'xterm'*)
                bindkey '[3~'     delete-char
                bindkey 'OH'      beginning-of-line
                bindkey 'OF'      end-of-line
                bindkey '[5~'     insert-last-word
                bindkey '[6~'     end-of-history
                bindkey '[1;5D'   backward-word
                bindkey '[1;5C'   forward-word
            ;;
            'rxvt'*)
                bindkey '[3~'     delete-char
                bindkey '[7~'     beginning-of-line
                bindkey '[8~'     end-of-line
                bindkey '[5~'     insert-last-word
                bindkey '[6~'     end-of-history
                bindkey 'Od'      backward-word
                bindkey 'Oc'      forward-word
            ;;
            'screen'*)
                bindkey '[3~'     delete-char
                bindkey '[1~'     beginning-of-line
                bindkey '[4~'     end-of-line
                bindkey '[5~'     insert-last-word
                bindkey '[6~'     end-of-history
                bindkey '[1;5D'   backward-word
                bindkey 'O5D'     backward-word
                bindkey 'OD'      backward-word
                bindkey '[1;5C'   forward-word
                bindkey 'O5C'     forward-word
                bindkey 'OC'      forward-word
            ;;
            'linux')
                bindkey '[3~'     delete-char
                bindkey '[1~'     beginning-of-line
                bindkey '[4~'     end-of-line
                bindkey '[5~'     insert-last-word
                bindkey '[6~'     end-of-history
                # mingetty doesn't distinguish between ^<LeftArrow> and <LeftArrow>.
            ;;
        esac
    ;;
    'Ossix')
        bindkey '[D'            backward-word       # option-left
        bindkey '[C'            forward-word        # option-right
        bindkey '[1;10D'      beginning-of-line   # shift-option-left
        bindkey '[1;10C'      end-of-line         # shift-option-right
    ;;
esac
####################################### }}}



# Aliases. {{{
# ... to add functionality.
alias chrome-get-rss='
    CHROME_RSS=0
    for num in `ps axwwo rss,command | grep -P "(google-|)chrome" | grep -v grep | sed "s/^\s*//g" | cut -d " " -f 1`
    do
        CHROME_RSS=$(($num * 1 + $CHROME_RSS))
    done
    print $CHROME_RSS; unset CHROME_RSS'
alias getip='curl ifconfig.me'
alias sudo='sudo '  # This enables alias, but not function, expansion on the next word.

# ... to save keystrokes.
alias -- \-='cd \-'
alias absname='readlink -m'
alias cep='call-embedded-perl'
alias chrome='google-chrome'
alias no='yes n'
if [[ `get_prop OS` == 'Linux' ]]; then
    alias open='xdg-open'
fi
alias rezsh='source ~/.zshrc'

# ... to enable 'default' options.
alias bc='bc -l'
alias emacs='emacs -nw'
alias fortune='fortune -c'
alias getpwdfs='getfstype .'
alias grep='grep --color=auto'
alias less='less -FRX'
alias units='units --verbose'

case `get_prop OS` in
    'Linux')
        alias ls='ls -F --color=auto'
    ;;
    'Ossix')
        alias ls='ls -FG'
    ;;
esac

# ... to compensate for me being an idiot.
alias rm='rm -i'
####################################### }}}



# Command functions. {{{
oh() {
    echo "oh $@"
}

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

reify() {
    # Turn redundant hard links into separate, identical files.
    for F in $@; do
        mv $F $F.rfy
        cp $F.rfy $F
        rm -f $F.rfy
    done
}

update-rc() {
    update-zshrc
    update-vimrc
}

update-zshrc() {
    if [ ! `get_prop have_git` ]; then
        print -l "git is required to do this, but it is not in your path.";
        return 1;
    fi

    local TMPDIR=`uuidgen`-ted
    pushd
    mkdir ~/$TMPDIR
    cd ~/$TMPDIR

    git clone git://github.com/tstein/ted-configs.git
    cp ted-configs/zshrc ~/.zshrc

    popd
    rm -rf ~/$TMPDIR

    source ~/.zshrc
    return 0;
}

update-vimrc() {
    rsync -aLze "ssh -p54848" ted@halberd.dyndns.org:~/.vimrc ~/.vimrc
}

call-embedded-perl() {
    local DEBUG_CEP
    if [[ "$1" == "debug" ]]; then
        DEBUG_CEP="TRUE"
        shift
    fi

    if [[ $ARGC -eq 0 ]]; then
        print -l "Which script would you like to run?"
        return 0;
    fi
    local SCRIPT="$1"
    shift

    if [[ "$DEBUG_CEP" == "TRUE" ]]; then
        perl -ne "print $F if s/#$SCRIPT#//" ~/.zshrc
    else
        perl -ne "print $F if s/#$SCRIPT#//" ~/.zshrc | perl -w \- $@
    fi
}
####################################### }}}



# Embedded Perl scripts. {{{
#
# To create a new script, write it here, with each line prefixed with #NAME#. It will be callable
# with `call-embedded-perl NAME`.

#localinfo#  # {{{
#localinfo#  # TODO: switch from grep -P to perl proper.
#localinfo#  $sysinfo = "";
#localinfo#  $buffer = `uname -s`;
#localinfo#  chomp($buffer);
#localinfo#      $sysinfo .= "Operating system:      $buffer\n";
#localinfo#  if (-e '/etc/issue') {
#localinfo#      $buffer = `head -n 1 /etc/issue`;
#localinfo#      # Arch (at least) puts `clear` in its /etc/issue.
#localinfo#      # This monstrosity fixes that.
#localinfo#      if ($buffer =~ /\x1b\x5b\x48\x1b\x5b\x32\x4a/) {
#localinfo#          $buffer = `head -n 2 /etc/issue | tail -n 1`;
#localinfo#          $buffer =~ s/ \\r.*//;
#localinfo#      }
#localinfo#      $buffer =~ s/\s*\\\S+//g;
#localinfo#      chomp($buffer);
#localinfo#      $sysinfo .= "Distro/release:        $buffer\n";
#localinfo#  }
#localinfo#  if (-e '/proc/cpuinfo') {
#localinfo#      $buffer = `grep -P '(?:model name|cpu\\s+:)' /proc/cpuinfo | head -n 1`;
#localinfo#      $buffer =~ s/^(?:model name|cpu)\s*:\s*(.+)/$1/;
#localinfo#      $buffer =~ s/\((?:R|TM)\)/ /gi;
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
#localinfo#  # }}}

#rpmstats#   # {{{
#rpmstats#   if (! -e '/bin/rpm') {
#rpmstats#       print("rpm not found. Are you sure this is an rpm-based system?\n");
#rpmstats#       exit(1);
#rpmstats#   }
#rpmstats#   print "Gathering info on installed rpms... This may take a few.\n";
#rpmstats#   @rpms = split(/\n/, `/bin/rpm -qa`);
#rpmstats#   foreach $rpm (@rpms) {
#rpmstats#       if ($rpm =~ /fc(\d{1,2})\.(\w+)$/) {
#rpmstats#           $rel = $1;
#rpmstats#           $arch = $2;
#rpmstats#           $releases{$rel} = () unless ($releases{$rel});
#rpmstats#           push(@{$releases{$rel}}, \$rpm);
#rpmstats#               $arches{$arch} = () unless ($arches{$arch});
#rpmstats#           push(@{$arches{$arch}}, \$rpm);
#rpmstats#       } else {
#rpmstats#           push(@unsortable, \$rpm);
#rpmstats#       }
#rpmstats#   }
#rpmstats#   print("\nFound $#rpms packages.\n");
#rpmstats#   print("By release:\n");
#rpmstats#   foreach $rel (sort {$b <=> $a} keys %releases) {
#rpmstats#       printf("    fc$rel: %d packages\n", $#{$releases{$rel}} + 1);
#rpmstats#   }
#rpmstats#   print("\nBy arch:\n");
#rpmstats#   foreach $arch (sort keys %arches) {
#rpmstats#       printf("    $arch: %d packages\n", $#{$arches{$arch}} + 1);
#rpmstats#   }
#rpmstats#   printf("\n%d packages unsorted.\n", $#unsortable);
#rpmstats#   # }}}

#automat#   # {{{
#automat#   # automat automates the unprivileged installation of packages from the Internet
#automat#   # when one cannot or does not want to use system package management. It uses
#automat#   # the following directories:
#automat#   #   ~/bin       Binaries or symbolic links, as appropriate.
#automat#   #   ~/.src      Untarred sources, and as a build directory.
#automat#   #   ~/.root     Install prefix (as in ./configure --prefix=).
#automat#
#automat#   if ($#ARGV < 0) {
#automat#       print("No packages specified.\n");
#automat#       exit(1);
#automat#   }
#automat#
#automat#   sub libevent {
#automat#       chdir("$ENV{'HOME'}/.src");
#automat#       `wget -qO- http://monkey.org/~provos/libevent-2.0.12-stable.tar.gz | tar -xzf-`;
#automat#       return $? if ($? != 0);
#automat#       chdir("libevent-2.0.12-stable");
#automat#       `./configure --prefix=$ENV{'HOME'}/.root`;
#automat#       return $? if ($? != 0);
#automat#       `make`;
#automat#       return $? if ($? != 0);
#automat#       `make install`;
#automat#       return $?;
#automat#   }
#automat#
#automat#   sub ack {
#automat#       `curl http://betterthangrep.com/ack-standalone > ~/bin/ack && chmod u+x ~/bin/ack #:3`;
#automat#       return $?;
#automat#   }
#automat#
#automat#   sub git {
#automat#       chdir("$ENV{'HOME'}/.src");
#automat#       `wget -qO- http://www.kernel.org/pub/software/scm/git/git-1.7.3.tar.bz2 | tar -xjf-`;
#automat#       return $? if ($? != 0);
#automat#       chdir("git-1.7.3");
#automat#       `./configure --prefix=$ENV{'HOME'}/.root --bindir=$ENV{'HOME'}/bin`;
#automat#       return $? if ($? != 0);
#automat#       `make`;
#automat#       return $? if ($? != 0);
#automat#       `make install`;
#automat#       return $?;
#automat#   }
#automat#
#automat#   sub hg {
#automat#       chdir("$ENV{'HOME'}/.root");
#automat#       `wget -qO- http://mercurial.selenic.com/release/mercurial-2.0.2.tar | tar -xzf-`;
#automat#       return $? if ($? != 0);
#automat#       chdir("mercurial-2.0.2");
#automat#       `make local`;
#automat#       return $? if ($? != 0);
#automat#       `ln -fs ../.root/mercurial-2.0.2/hg $ENV{'HOME'}/bin/hg`;
#automat#       return $?;
#automat#   }
#automat#
#automat#   sub htop {
#automat#       chdir("$ENV{'HOME'}/.src");
#automat#       `wget -qO- http://downloads.sourceforge.net/project/htop/htop/0.9/htop-0.9.tar.gz | tar -xzf-`;
#automat#       return $? if ($? != 0);
#automat#       chdir("htop-0.9");
#automat#       `./configure --prefix=$ENV{'HOME'}/.root --bindir=$ENV{'HOME'}/bin`;
#automat#       return $? if ($? != 0);
#automat#       `make`;
#automat#       return $? if ($? != 0);
#automat#       `make install`;
#automat#       return $?;
#automat#   }
#automat#
#automat#   sub keychain {
#automat#       chdir("$ENV{'HOME'}/.src");
#automat#       `wget -qO- http://www.funtoo.org/archive/keychain/keychain-2.7.1.tar.bz2 | tar -xjf-`;
#automat#       return $? if ($? != 0);
#automat#       `ln -fs ../.src/keychain-2.7.1/keychain $ENV{'HOME'}/bin/keychain`;
#automat#       return $? if ($? != 0);
#automat#   }
#automat#
#automat#   sub tmux {
#automat#       $ret = libevent();
#automat#       return $ret if ($ret != 0);
#automat#       $ENV{'CPPFLAGS'} = "-I $ENV{'HOME'}/.root/include";
#automat#       $ENV{'LDFLAGS'} = "-L $ENV{'HOME'}/.root/include -L $ENV{'HOME'}/.root/lib";
#automat#       chdir("$ENV{'HOME'}/.src");
#automat#       `wget -qO- http://downloads.sourceforge.net/project/tmux/tmux/tmux-1.4/tmux-1.4.tar.gz | tar -xzf-`;
#automat#       return $? if ($? != 0);
#automat#       chdir("tmux-1.4");
#automat#       `./configure`;
#automat#       return $? if ($? != 0);
#automat#       `make`;
#automat#       return $? if ($? != 0);
#automat#       `cp tmux $ENV{'HOME'}/bin`;
#automat#       return $?;
#automat#   }
#automat#
#automat#   sub vim {
#automat#       chdir("$ENV{'HOME'}/.src");
#automat#       `wget -qO- ftp://ftp.vim.org/pub/vim/unix/vim-7.3.tar.bz2 | tar -xjf-`;
#automat#       return $? if ($? != 0);
#automat#       chdir("vim73");
#automat#       `./configure --prefix=$ENV{'HOME'}/.root --bindir=$ENV{'HOME'}/bin`;
#automat#       return $? if ($? != 0);
#automat#       `make`;
#automat#       return $? if ($? != 0);
#automat#       `make install`;
#automat#       return $?;
#automat#   }
#automat#
#automat#   %progs = (
#automat#       'ack'       => \&ack,
#automat#       'git'       => \&git,
#automat#       'hg'        => \&hg,
#automat#       'keychain'  => \&keychain,
#automat#       'htop'      => \&htop,
#automat#       'tmux'      => \&tmux,
#automat#       'vim'       => \&vim,
#automat#   );
#automat#
#automat#   $home = $ENV{'HOME'};
#automat#   foreach $dir ("$home/bin", "$home/.src", "$home/.root") {
#automat#       unless (-d $dir) {
#automat#           mkdir($dir);
#automat#       }
#automat#   }
#automat#
#automat#   foreach $arg (@ARGV) {
#automat#       if ($progs{$arg}) {
#automat#           $ret = $progs{$arg}();
#automat#           print("automat: $arg " . ($ret == 0 ? "installed successfully." : "not installed!") . "\n");
#automat#       } else {
#automat#           print("Don't know how to 'mat $arg!\n")
#automat#       }
#automat#   }
#automat#   # }}}
####################################### }}}



# Space expansion: cause a space to expand to certain text given what's already on the line. {{{
typeset -A abbreviations
abbreviations=(
    'lame'              'lame -V 0 -q 0 -m j --replaygain-accurate --add-id3v2'
)
case `get_prop OS` in
    'Linux')
        abbreviations+=(
            'df'                'df -hT --total'
            'ps'                'ps axwwo user,pid,ppid,pcpu,cputime,nice,pmem,rss,lstart=START,stat,tname,command'
            'pacman'            'pacman-color'
            'sudo pacman'       'sudo pacman-color'
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
####################################### }}}



# Interface functions. {{{
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
    print -l "\nLooks like it's your first time here.\n"
    print -l ".zlocal for "`hostname`" created on `date`" >> ~/.zlocal
    print -l "configuration:\n" >> ~/.zlocal
    call-embedded-perl localinfo | tee -a ~/.zlocal
    sed -i -e 's/.*/# &/' ~/.zlocal
    print >> ~/.zlocal
    print -l "\nWhat color would you like your prompt on this machine to be? Pick one."
    print -n "[red|green|blue|cyan|magenta|yellow|white|black]: "
    local CHOICE=""
    read CHOICE
    case "$CHOICE" in
        'black')
            print -l "Really? If you say so..."
        ;&
        ('red'|'green'|'blue'|'cyan'|'magenta'|'yellow'|'white'))
            CHOICE=`echo $CHOICE | tr 'a-z' 'A-Z'`
            print -l "PR_COLOR=\$PR_$CHOICE\n" >> ~/.zlocal
        ;;
        *)
            print -l "You get blue. Set PR_COLOR later if you want anything else."
        ;;
    esac
    print -l 'All the above information has been saved to ~/.zlocal. Happy zshing!'
    trap 2
}

# cornmeter is a visual battery meter meant for a prompt. {{{
# This function spits out the meter as it should appear at call time.
drawCornMeter() {
    for var in WIDTH STEP LEVEL CHARGING SPPOWER CHARGE CAPACITY; do; eval local $var=""; done
    WIDTH=$1
    STEP=$((100.0 / $WIDTH))
    case `get_prop OS` in
        'Linux')
            LEVEL=`acpi -b | perl -ne '/(\d{1,3}\%)/; $LVL = $1; $LVL =~ s/\%//; print $LVL;'`
            LEVEL=$(($LEVEL * 1.0))
            CHARGING=`acpi -a | perl -ne 'if (/on-line/) { print $1; }'`
        ;;
        'Ossix')
            SPPOWER=`system_profiler SPPowerDataType`
            CHARGE=`print $SPPOWER | perl -ne 'if (/Charge Remaining.* (\d+)/) { print $1; }'`
            CAPACITY=`print $SPPOWER | perl -ne 'if (/Full Charge Capacity.* (\d+)/) { print $1; }'`
            LEVEL=$((100.0 * $CHARGE / $CAPACITY))
            CHARGING=`print $SPPOWER | perl -ne 'if (/Charging: (\w+)/) { if ($1 =~ "Yes") { print "Yes"; } }'`
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
                print -n "C"
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
# TODO: Switch from precmd_functions to chpwd_functions
rprompt_git_status() {
    local GITBRANCH=""
    git status &> /dev/null
    if (( $? != 128 )); then
        GITBRANCH=$(git symbolic-ref HEAD 2>/dev/null)
        print -n " ±:${GITBRANCH#refs/heads/}"
        if [ ! "`git status | grep clean`" ]; then
            print -n "(*)"
        fi
    fi
}

rprompt_hg_status() {
    hg status &> /dev/null
    if (( $? != 255 )); then
        print -n " ☿:"
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

    if [ `get_prop have_git` ]; then
        GIT=`rprompt_git_status`
    fi

    if [ `get_prop have_hg` ]; then
        HG=`rprompt_hg_status`
    fi

    COND_RETVAL='%(?..{%?})'

    if [ `get_prop am_laptop` ]; then
        if (( $BATT_METER_WIDTH > 0 )); then
            CORNMETER=`drawCornMeter $BATT_METER_WIDTH`
        else
            CORNMETER=`drawCornMeter $(($COLUMNS / 10))`
        fi
    fi

    BOLD_OFF='%b'
    RPROMPT="$PR_CYAN$BOLD_ON"["$DIR$GIT$HG"]"$COND_RETVAL$CORNMETER$BOLD_OFF"
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
if [[ "$PROMPT" == "$old_vals[PROMPT]" ]]; then
    PROMPT=$PR_COLOR"%B[%n@%m %D{%H:%M}]%(2L.{$SHLVL}.)\%#%b "
fi
PROMPT2=$PR_GREEN'%B%_>%b '
RPROMPT=$PR_CYAN'%B[%~]%(?..{%?})%b' # For reference only. This is clobbered by update_rprompt().
SPROMPT=$PR_MAGENTA'zsh: correct '%R' to '%r'? '$PR_NO_COLOR
unset old_vals

precmd_functions=(precmd_update_title update_rprompt)
preexec_functions=(preexec_update_title)

#TODO: Check if we are a login shell. This could hang a script without that.
if [ `get_prop have_keychain` ]; then
    keychain -Q -q $ssh_key_list
    source ~/.keychain/${HOST}-sh
fi
####################################### }}}



# Finally, source additional configuration.
if [ -d ~/.zsh ]; then
    for zfile in `ls ~/.zsh/*.zsh`; do
        source $zfile
    done
fi
####################################### }}}
# ZSH IS GO
#######################################
# vim:filetype=zsh foldmethod=marker autoindent expandtab shiftwidth=4
# Local variables:
# mode: sh
# End:

