#!/bin/zsh

export PATH=~/.local/bin:$PATH

# high DPI settings
export GDK_SCALE=2
export QT_SCALE_FACTOR=2

# Suppresses attempts to connect to the Gnome Accessibility Toolkit over a
# nonexistent dbus instance. e.g.,
# ** (xfce4-notifyd:1216): WARNING **: Couldn't connect to accessibility bus: Failed to connect to socket /tmp/dbus-KqbaHyU9MY: Connection refused
export NO_AT_BRIDGE=1

numlockx on&
setxkbmap -option compose:caps

# Session daemons and applets.
taffybar&
xscreensaver -no-splash&
/usr/lib64/xfce4/notifyd/xfce4-notifyd&
nm-applet&
pnmixer&
syncthing-gtk&

if [ -e ~/.xsession.local ]; then
    . ~/.xsession.local
fi

# Restore last random wallpaper.
source ~/.fehbg

# If we're not in another desktop environment, start xmonad.
if [[ "$DESKTOP_SESSION" == "xinit-compat" ]]; then
  # Start the best compositor we have available.
  if [ $(which compton 2>/dev/null) ]; then
    compton --backend glx&
  else
    xcompmgr -c&
  fi

  # Lie about current desktop for xdg-open. In particular, Chrome opens
  # everything in Firefox(?!) if this isn't set.
  export XDG_CURRENT_DESKTOP=XFCE
  export _JAVA_AWT_WM_NONREPARENTING=1  # Without this, Java makes grey rectangles.
  exec xmonad
fi
