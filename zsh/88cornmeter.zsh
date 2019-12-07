# cornmeters are capacity bars for the rprompt.
# This function spits out the meter as it should appear at call time.
cornmeter() {
  local LEVEL=$1
  local MAX=$2
  local TEXT=${3:-""}
  local WARN=${4:-95}
  local CRIT=${5:-30}

  local WIDTH=$(($COLUMNS / 10))
  local LEVEL_PCT=$(($LEVEL * 100.0 / $MAX))
  local STEP=$(($MAX * 1.0 / $WIDTH))
  local TEXT_LEN=$(print -n "$TEXT" | wc -c)

  print -n $PR_WHITE"["
  if (($LEVEL_PCT > 100)); then
    while (($LEVEL > $MAX)); do
      LEVEL=$(($LEVEL - $MAX))
      TEXT="$TEXT!"
      TEXT_LEN=$(($TEXT_LEN + 1))
    done
    print -n $PR_GREEN
  elif (($LEVEL_PCT < $CRIT)); then
    print -n $PR_RED
  elif (($LEVEL_PCT < $WARN)); then
    print -n $PR_YELLOW
  else
    print -n $PR_WHITE
  fi

  for (( i = 0; i < $WIDTH; i++ ))
  do
    if (($(($i + $TEXT_LEN)) == $WIDTH)); then
      print -n $TEXT
      break
    fi

    if (($LEVEL >= 0.0)); then
      if (($LEVEL <= $(($STEP / 2.0)))); then
        print -n "\-"
      else
        print -n "="
      fi
    else
      print -n " "
    fi
    LEVEL=$(($LEVEL - $STEP))
  done
  print -n $PR_WHITE"]"
}
