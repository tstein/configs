# Higher-order functions for zsh.

prefix() {
    local PREFIX=$1
    if [ ! "$PREFIX" ]; then
      echo "Usage: prefix str [args]"
      echo "  Prepend string to each line read and print it. args are passed to cat."
      return 1;
    fi
    shift
    cat $@ | sed "s/^/$PREFIX/"
}

apply1() {
  if (( $# != 2 )); then
    print 'usage: apply1 COMMAND ARG'
    print 'Apply COMMAND to ARG. If COMMAND contains tokens consisting of a'
    print '  single underscore, ARG will replace it. Otherwise, ARG will be the'
    print '  last argument passed to COMMAND.'
    return
  fi
  local COMMAND=${@[0]}
  local ARG=${@[1]}
  local EXEC=''
  local APPENDARG='yep'
  for TOKEN in "${=COMMAND}"; do
    if [[ $TOKEN == '$_' ]]; then
      EXEC="$EXEC $ARG"
      APPENDARG='nope'
    elif [[ $TOKEN =~ '\$\{_\}' ]]; then
      EXEC="$EXEC ${TOKEN//\$\{_\}/$ARG}"
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

in() {
  if (( $# < 2 )); then
    print 'usage: in DIR COMMAND [ARG...]'
    print 'Run COMMAND with ARGS in DIR.'
    return
  fi
  local DIR="`readlink -m ${@[0]}`"
  if [ ! -d $DIR ]; then
    print "in: no such directory: $DIR"
    return 255
  fi
  pushd $DIR
  print "in: $DIR"
  eval "${@[1,-1]}"
  local RETVAL=$?
  popd
  return $RETVAL
}

map() {
  if [[ $1 == -p ]]; then
    local BG="&"
    shift
  fi
  if (( $# < 2 )); then
    print 'usage: map [-p] COMMAND [ARG...]'
    print 'Apply COMMAND to each ARG. If run with -p, do it in parallel.'
    return
  fi
  local COMMAND=${@[0]}
  for ARG in ${@[1,-1]}; do
    eval "apply1 $COMMAND $ARG | prefix \"$COMMAND $ARG> \" $BG"
  done
  wait
}

alias parmap=map -p

filter() {
  if (( $# < 2 )); then
    print 'usage: filter COMMAND [ARG...]'
    print 'Apply COMMAND to each ARG and print the ARGs for which COMMAND returned 0, space-separated.'
    return
  fi
  local COMMAND=${@[0]}
  for ARG in ${@[1,-1]}; do
    apply1 $COMMAND $ARG >/dev/null 2>/dev/null
    if (( $? == 0 )); then
      print -n "$ARG "
    fi
  done
  print
}
