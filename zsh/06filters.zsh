hi() {
  cat - | sed -E "s/($1)/\x1b[94;1m\1\x1b[0m/"
}

prefix() {
  local PREFIX=$1
  if [ ! "$PREFIX" ]; then
    echo "Usage: prefix str"
    echo "  Prepend string to each line read and print it."
    return 1;
  fi
  while read line; do
    print "$PREFIX$line"
  done
}

# more precise than moreutils' ts
tstamp() {
  while read line; do
    print "`date --rfc-3339=ns ` $line"
  done
}

