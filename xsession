#!/bin/zsh
numlockx on&
setxkbmap -option compose:caps&
xsetroot -cursor_name left_ptr&
source ~/.fehbg&
xcompmgr -cfnFD 3&

# Startup programs.
/usr/libexec/gnome-settings-daemon&
/usr/lib64/xfce4/notifyd/xfce4-notifyd&
xscreensaver&
tint2&
nm-applet&
gnome-sound-applet&
dropbox start&
ibus-daemon&
if [ -e ~/.xsession.local ]; then
    . ~/.xsession.local
fi

exec dbus-launch ck-launch-session xmonad

