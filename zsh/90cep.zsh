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
        perl -ne "print $F if s/#$SCRIPT#//" ~/.zsh/90cep.zsh
    else
        perl -ne "print $F if s/#$SCRIPT#//" ~/.zsh/90cep.zsh | perl -w \- $@
    fi
}

alias cep='call-embedded-perl'

# Embedded Perl scripts. Hoo boy. {{{
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

#automat#   # {{{
#automat#   # automat automates the unprivileged installation of packages from the Internet
#automat#   # when one cannot or does not want to use system package management. It uses
#automat#   # the following directories:
#automat#   #   ~/.local/bin    Binaries or symbolic links, as appropriate.
#automat#   #   ~/.local/tmp    Untarred sources, and as a build directory.
#automat#   #   ~/.local        Install prefix (as in ./configure --prefix=).
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
#automat#       `./configure --prefix=$ENV{'HOME'}/.local`;
#automat#       return $? if ($? != 0);
#automat#       `make`;
#automat#       return $? if ($? != 0);
#automat#       `make install`;
#automat#       return $?;
#automat#   }
#automat#
#automat#   sub ack {
#automat#       `curl http://betterthangrep.com/ack-standalone > ~/.local/bin/ack && chmod u+x ~/.local/bin/ack #:3`;
#automat#       return $?;
#automat#   }
#automat#
#automat#   sub git {
#automat#       chdir("$ENV{'HOME'}/.src");
#automat#       `wget -qO- https://git-core.googlecode.com/files/git-1.8.2.tar.gz | tar -xzf-`;
#automat#       return $? if ($? != 0);
#automat#       chdir("git-1.8.2");
#automat#       `./configure --prefix=$ENV{'HOME'}/.local --bindir=$ENV{'HOME'}/.local/bin`;
#automat#       return $? if ($? != 0);
#automat#       `make`;
#automat#       return $? if ($? != 0);
#automat#       `make install`;
#automat#       return $?;
#automat#   }
#automat#
#automat#   sub hg {
#automat#       chdir("$ENV{'HOME'}/.local");
#automat#       `wget -qO- http://mercurial.selenic.com/release/mercurial-2.0.2.tar | tar -xzf-`;
#automat#       return $? if ($? != 0);
#automat#       chdir("mercurial-2.0.2");
#automat#       `make local`;
#automat#       return $? if ($? != 0);
#automat#       `ln -fs ../.local/mercurial-2.0.2/hg $ENV{'HOME'}/.local/bin/hg`;
#automat#       return $?;
#automat#   }
#automat#
#automat#   sub htop {
#automat#       chdir("$ENV{'HOME'}/.src");
#automat#       `wget -qO- http://downloads.sourceforge.net/project/htop/htop/0.9/htop-0.9.tar.gz | tar -xzf-`;
#automat#       return $? if ($? != 0);
#automat#       chdir("htop-0.9");
#automat#       `./configure --prefix=$ENV{'HOME'}/.local --bindir=$ENV{'HOME'}/.local/bin`;
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
#automat#       `ln -fs $ENV{'HOME'}/.src/keychain-2.7.1/keychain $ENV{'HOME'}/.local/bin/keychain`;
#automat#       return $? if ($? != 0);
#automat#   }
#automat#
#automat#   sub tmux {
#automat#       $ret = libevent();
#automat#       return $ret if ($ret != 0);
#automat#       $ENV{'CPPFLAGS'} = "-I $ENV{'HOME'}/.local/include";
#automat#       $ENV{'LDFLAGS'} = "-L $ENV{'HOME'}/.local/include -L $ENV{'HOME'}/.local/lib";
#automat#       chdir("$ENV{'HOME'}/.src");
#automat#       `wget -qO- http://downloads.sourceforge.net/project/tmux/tmux/tmux-1.9/tmux-1.9a.tar.gz | tar -xzf-`;
#automat#       return $? if ($? != 0);
#automat#       chdir("tmux-1.9a");
#automat#       `./configure`;
#automat#       return $? if ($? != 0);
#automat#       `make`;
#automat#       return $? if ($? != 0);
#automat#       `cp tmux $ENV{'HOME'}/.local/bin`;
#automat#       return $?;
#automat#   }
#automat#
#automat#   sub vim {
#automat#       chdir("$ENV{'HOME'}/.src");
#automat#       `wget -qO- ftp://ftp.vim.org/pub/vim/unix/vim-7.4.tar.bz2 | tar -xjf-`;
#automat#       return $? if ($? != 0);
#automat#       chdir("vim74");
#automat#       `./configure --prefix=$ENV{'HOME'}/.local --bindir=$ENV{'HOME'}/.local/bin --enable-pythoninterp --enable-perlinterp`;
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
#automat#   foreach $dir ("$home/.local/bin", "$home/.src", "$home/.local") {
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
