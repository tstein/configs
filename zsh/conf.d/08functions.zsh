function do-and-tell() {
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

