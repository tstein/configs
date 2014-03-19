# Higher-order functions for zsh.

function apply1() {
  if (( $# != 2 )); then
    print 'usage: apply1 COMMAND ARG'
    print 'Apply COMMAND to ARG. If COMMAND contains tokens consisting of a'
    print '  single underscore, ARG will replace it. Otherwise, ARG will be the'
    print '  last argument passed to COMMAND.'
    return
  fi
  local COMMAND=$@[1]
  local ARG=$@[2]
  local EXEC=''
  local APPENDARG='yep'
  for TOKEN in "${(s/ /)COMMAND}"; do
    if [[ $TOKEN == '_' ]]; then
      EXEC="$EXEC $ARG"
      APPENDARG='nope'
    else
      EXEC="$EXEC $TOKEN "
    fi
  done
  if [[ $APPENDARG == 'yep' ]]; then
    EXEC="$EXEC $ARG"
  fi
  eval $EXEC
}

function in() {
  if (( $# < 2 )); then
    print 'usage: in DIR COMMAND [ARG...]'
    print 'Run COMMAND with ARGS in DIR.'
    return
  fi
  local DIR=`readlink -m $@[1]`
  if [ ! -d $DIR ]; then
    print "in: no such directory: $DIR"
    return 255
  fi
  pushd $DIR
  print "in: $DIR"
  eval "$@[2,-1]"
  local RETVAL=$?
  popd
  return $RETVAL
}

function map() {
  if (( $# < 2 )); then
    print 'usage: map COMMAND [ARG...]'
    print 'Apply COMMAND to each ARG in sequence.'
    return
  fi
  local COMMAND=$@[1]
  for ARG in $@[2,-1]; do
    apply1 $COMMAND $ARG
  done
}

function filter() {
  if (( $# < 2 )); then
    print 'usage: filter COMMAND [ARG...]'
    print 'Apply COMMAND to each ARG and print the ARGs for which COMMAND returned 0, space-separated.'
    return
  fi
  local COMMAND=$@[1]
  for ARG in $@[2,-1]; do
    apply1 $COMMAND $ARG >/dev/null 2>/dev/null
    if (( $? == 0 )); then
      print -n "$ARG "
    fi
  done
  print
}
