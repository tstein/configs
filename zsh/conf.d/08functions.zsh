function maclookup() {
  # ssh into the router and retrieve all MAC addresses known for the given
  # hostname.
  if [[ $# != 1 ]]; then
    print "usage: $0 HOST"
    return
  fi
  router=$(ip route show default | awk '{print $3}')
  for mac in `ssh $router grep $1 /etc/dnsmasq.conf | cut -d= -f2 | tr , '\n' | head -n -1`; do
    print $mac
  done
}

function wolh() {
  # Wake-on-LAN a machine by hostname. WOLs every MAC address it can find.
  if [[ $# != 1 ]]; then
    print "usage: $0 HOST"
    return
  fi
  for mac in `maclookup $1`; do
    wol $mac
  done
}

