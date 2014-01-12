# Higher-order functions for zsh.

function filter() {
  if (( $# == 0 )); then
    print 'usage: filter COMMAND [ARG...]'
    print 'Apply COMMAND to each ARG and print the ARGs for which COMMAND returned 0, space-separated.'
    return
  fi
  local COMMAND=$@[1]
  for ARG in $@[2,-1]; do
    eval "$COMMAND $ARG >/dev/null 2>/dev/null"
    if (( $? == 0 )); then
      print -n "$ARG "
    fi
  done
  print
}

function map() {
  if (( $# == 0 )); then
    print 'usage: map COMMAND [ARG...]'
    print 'Apply COMMAND to each ARG in sequence.'
    return
  fi
  local COMMAND=$@[1]
  for ARG in $@[2,-1]; do
    eval "$COMMAND $ARG"
  done
}
