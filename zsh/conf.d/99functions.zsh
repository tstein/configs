# A place to collect functions that are worth checking in, but not worth
# checking in as scripts.

# Copy ghostty's terminfo, since it isn't getting distributed properly yet. 
# See https://github.com/ghostty-org/ghostty/issues/2542#issuecomment-2629819170
copy-ghostty-terminfo() {
  if [[ $# != 1 ]]; then
    print "usage: $0 \$HOST"
    print "  Copy the terminfo for ghostty to \$HOST via ssh."
    return 255
  fi
  infocmp -x xterm-ghostty | ssh $1 -- tic -x -
}

# Look up the host for a MAC address. Assumes the router has this info, uses
# dnsmasq, and accepts ssh.
maclookup() {
  if [[ $# != 1 ]]; then
    print "usage: $0 \$MACADDR"
    cat <<EOF
  Resolve \$MACADDR to a hostname. Expects that:
  * the default route's next hop is a server that runs dnsmasq
  * and accepts ssh connections
  * and that the server has a dhcp-host directive for this MAC address
EOF
    return 255
  fi
  local ROUTER=$(ip route show default | cut -d " " -f 3)
  local DHCPHOST=$(ssh ${ROUTER} grep -i "$1" /etc/dnsmasq.conf)
  if [[ -z ${DHCPHOST} ]]; then
    print "Couldn't resolve MAC address ${1} in ${ROUTER}'s dnsmasq.conf."
    return 1
  fi
  print ${DHCPHOST} | rev | cut -d , -f 1 | rev
}

# Convert Pixel photo and video names from their native format to one I like.
regularize-pixel-phots() {
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
