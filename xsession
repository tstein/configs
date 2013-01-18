#!/bin/zsh
numlockx on&
setxkbmap -option compose:caps
xsetroot -cursor_name left_ptr&
xcompmgr -c&

# Startup programs.
wmname LG3D     # For Java. (read: Minecraft.)
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

# Gnome will fight over this.
sleep 2
source ~/.fehbg

# Lie about current desktop for xdg-open. In particular, Chrome opens everything
# in Firefox(?!) if this isn't set.
export XDG_CURRENT_DESKTOP=XFCE
exec dbus-launch ck-launch-session xmonad

