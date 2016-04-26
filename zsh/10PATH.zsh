# Save our system-given path in BASEPATH and reset PATH to that in each
# subshell. Without this, PATH gets gross and redundant.
if [[ "$_BASEPATH" == "" ]]; then
    export _BASEPATH=$PATH
else
    export PATH=$_BASEPATH
fi

if [[ `get_prop OS` == 'Ossix' ]]; then
  export PATH=/usr/local/bin:$PATH
fi

# Ensure the personal bin/ exists so other scripts can modify it.
if [ ! -d ~/.local/bin ]; then
    mkdir ~/.local/bin
fi
export PATH=~/.local/bin:$PATH

