if [[ `get_prop OS` == 'Ossix' ]]; then
  export HOMEBREW_NO_ANALYTICS=1
  # /usr/local/bin gets added, but sbin does not.
  export PATH=/usr/local/sbin:$PATH
  # Pick up brew's python.
  export PATH="/usr/local/opt/python/libexec/bin:$PATH"
fi
