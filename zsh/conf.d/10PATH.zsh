# Save our system-given path in BASEPATH and reset PATH to that in each
# subshell. Without this, PATH gets gross and redundant.
if [[ "$_BASEPATH" == "" ]]; then
    export _BASEPATH=$PATH
else
    PATH=$_BASEPATH
fi

case ":${PATH}:" in
  *:/sbin:*|*:/usr/sbin:*)
    ;;
  *)
    PATH=$PATH:/sbin
    ;;
esac

if [[ `get_prop OS` == 'Ossix' ]]; then
  PATH=/usr/local/bin:$PATH
fi

# Ensure the personal bin/ exists so other scripts can modify it.
if [ ! -d ~/.local/bin ]; then
    mkdir ~/.local/bin
fi
PATH=~/.local/bin:$PATH
