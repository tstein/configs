#!/bin/zsh

export PATH=~/.local/bin:$PATH

export GTK_THEME=Adwaita:dark
# demand hidpi
export GDK_SCALE=2
export QT_SCALE_FACTOR=2

# Lie about current desktop for xdg-open. In particular, Chrome opens
# everything in Firefox(?!) if this isn't set.
export XDG_CURRENT_DESKTOP=XFCE

export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
export XMODIFIERS=@im=ibus

# Suppresses attempts to connect to the Gnome Accessibility Toolkit over a
# nonexistent dbus instance. e.g.,
# ** (xfce4-notifyd:1216): WARNING **: Couldn't connect to accessibility bus: Failed to connect to socket /tmp/dbus-KqbaHyU9MY: Connection refused
export NO_AT_BRIDGE=1

# keyboard
numlockx on&
setxkbmap -option compose:caps

# Restore last random wallpaper.
source ~/.fehbg
# Start window management.
compton --backend glx --vsync drm&
i3&; I3_PID=$!
sleep 1     # let i3 get going before polybars
polybars&

# Session daemons and applets.
xscreensaver -no-splash&
/usr/lib64/xfce4/notifyd/xfce4-notifyd&

ibus-daemon&
nm-applet&
pnmixer&
syncthing-gtk&
xfce4-power-manager&

# Apps that live in the tray.
clementine&
keepassxc&

if [ -e ~/.xsession.local ]; then
    . ~/.xsession.local
fi

wait $I3_PID
