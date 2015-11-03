#!/bin/zsh

PATH=~/.local/bin:$PATH

numlockx on&
setxkbmap -option compose:caps
xsetroot -cursor_name left_ptr&

# Session daemons.
xscreensaver -no-splash&
dropbox start&
ibus-daemon&
/usr/lib64/xfce4/notifyd/xfce4-notifyd&

# Tray and applets.
trayer --monitor primary --edge top --align right --height 24 --width 15 \
  --transparent true --alpha 0 --tint black --distancefrom right --distance 255&
nm-applet&
pnmixer&

if [ -e ~/.xsession.local ]; then
    . ~/.xsession.local
fi

# Gnome will fight over this.
sleep 2
source ~/.fehbg

# If we're not in another desktop environment, start xmonad.
if [[ "$DESKTOP_SESSION" == "xinit-compat" ]]; then
    xcompmgr -c&
    wmname LG3D     # For Java (read: Minecraft).
    # Lie about current desktop for xdg-open. In particular, Chrome opens
    # everything in Firefox(?!) if this isn't set.
    export XDG_CURRENT_DESKTOP=XFCE
    exec dbus-launch xmonad
fi

