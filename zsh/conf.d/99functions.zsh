# A place to collect functions that are worth checking in, but not worth
# checking in as scripts.

function copy-ghostty-terminfo() {
  # https://github.com/ghostty-org/ghostty/issues/2542#issuecomment-2629819170
  if [[ $# != 1 ]]; then
    print "usage: $0 \$HOST"
    print "  Copy the terminfo for ghostty to \$HOST via ssh."
    return 255
  fi
  infocmp -x xterm-ghostty | ssh $1 -- tic -x -
}

function do-and-tell() {
  if [[ $# == 0 ]]; then
    print "usage: $0 ..."
    print "  Run a command and its arguments. When it completes, tell ted how it went."
    return 255
  fi

  start=$(cut -d ' ' -f 1 /proc/uptime)
  eval $@
  retcode=$?
  duration=$(($(cut -d ' ' -f 1 /proc/uptime) - $start))
  # No need to create unread messages if it returns immediately.
  if [[ $duration > 1.0 ]]; then
    duration_s=$(printf '%.1fs' $duration)
    # Assume tell is set up.
    if [[ $retcode == 0 ]]; then
      tell ted "${HOST}: \`$*\` completed in ${duration_s}"
    else
      tell ted "${HOST}: \`$*\` returned ${retcode} in ${duration_s}"
    fi
  fi
  return retcode
}

function maclookup() {
  if [[ $# != 1 ]]; then
    print "usage: $0 MACADDR"
    cat <<EOF
  Resolve MACADDR to a hostname. Expects that:
  * the default route's next hop is a server that runs dnsmasq
  * and accepts ssh connections
  * and that the server has a dhcp-host directive for this MAC address
EOF
    return 255
  fi
  router=$(ip route show default | cut -d " " -f 3)
  dhcphost=$(ssh ${router} grep -i "$1" /etc/dnsmasq.conf)
  if [[ -z ${dhcphost} ]]; then
    print "Couldn't resolve MAC address ${1} in ${router}'s dnsmasq.conf."
    return 1
  fi
  print ${dhcphost} | rev | cut -d , -f 1 | rev
}

# Convert Pixel photo and video names from their native format to one I like.
function regularize-pixel-phots() {
  if [[ $# != 1 ]]; then
    print "usage: $0 DIR"
    print "  Convert all Pixel-camera-named media files in DIR to something cleaner."
    return 255
  fi

  for i in PXL_*; do
    create=$(exiftool -T -CreateDate $i | sed 's/:/-/' | sed 's/:/-/')
    # mp4s have this field set, but zeroed.
    if [[ $create == "0000-00-00 00:00:00" ]]; then
      print "$i no valid CreateDate - using btime"
      create=$(stat -c \%w $i | cut -d . -f 1)
    fi
    ext=$(print $i | grep -oP '\.\w+$')
    dst="$create$ext"
    if [ -e $dst ]; then
      print "want to move $i to $dst, but there's already something there"
      return 255
    fi
    mv "$i" "$dst"
    print "moved ${i} to ${dst}"
  done
}

# Wake-on-LAN a machine by hostname. WOLs every MAC address it can find.
function wolh() {
  if [[ $# != 1 ]]; then
    print "usage: $0 HOST"
    cat <<EOF
  Look up the MAC addresses for HOST and wake-on-LAN them all. Expects that:
  * the default route's next hop is a server that runs dnsmasq
  * and accepts ssh connections
  * and that the server has a dhcp-host directive for this host
EOF
    return 255
  fi

  host=$1
  router=$(ip route show default | awk '{print $3}')
  for mac in `ssh ${router} grep ${host} /etc/dnsmasq.conf | cut -d= -f2 | tr , '\n' | head -n -1`; do
    wol $mac
  done
}
