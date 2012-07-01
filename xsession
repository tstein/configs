#!/bin/zsh
numlockx on
setxkbmap -option compose:caps
xsetroot -cursor_name left_ptr
source ~/.fehbg
xcompmgr -cfnFD 3&

# Startup programs.
/usr/libexec/notification-daemon&
xscreensaver&
tint2&
nm-applet&
gnome-sound-applet&
if [ -e ~/.xsession.local ]; then
    . ~/.xsession.local
fi

exec ck-launch-session xmonad

