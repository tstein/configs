#!/bin/zsh

export PATH=~/.local/bin:$PATH

export GTK_THEME=Adwaita:dark
# demand hidpi
export GDK_SCALE=2
export GDK_DPI_SCALE=.8
export QT_AUTO_SCREEN_SCALE_FACTOR=1

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
picom --vsync&
i3&; I3_PID=$!
sleep 1     # let i3 get going before polybars
polybars&

# Session daemons and applets.
xscreensaver -no-splash&
/usr/lib64/xfce4/notifyd/xfce4-notifyd&

ibus-daemon&
nm-applet&
(sleep 5; volumeicon)&
xfce4-power-manager&

# Apps that live in the tray.
strawberry&
keepassxc&

if [ -e ~/.xsession.local ]; then
    . ~/.xsession.local
fi

wait $I3_PID
