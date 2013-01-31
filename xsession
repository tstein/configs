#!/bin/zsh
numlockx on&
setxkbmap -option compose:caps
xsetroot -cursor_name left_ptr&

# Startup programs.
/usr/libexec/gnome-settings-daemon&
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

# If we're not in another desktop environment, start xmonad.
if [[ "$DESKTOP_SESSION" == "xinit-compat" ]]; then
    xcompmgr -c&
    wmname LG3D     # For Java. (read: Minecraft.)
    /usr/lib64/xfce4/notifyd/xfce4-notifyd&
    # Lie about current desktop for xdg-open. In particular, Chrome opens
    # everything in Firefox(?!) if this isn't set.
    export XDG_CURRENT_DESKTOP=XFCE
    exec dbus-launch ck-launch-session xmonad
fi

