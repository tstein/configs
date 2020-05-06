# Set up the ~/.local hierarchy.

if [ ! -d ~/.local ]; then
    mkdir ~/.local
fi
SUBDIRS=(bin include lib share tmp)
for DIR in $SUBDIRS; do
    if [ ! -d ~/.local/$DIR ]; then
        mkdir ~/.local/$DIR
    fi
done
unset SUBDIRS

# For some unfathomable reason, ld.so considers paths with empty elements in
# LD_LIBRARY_PATH like `/a:` or `/a::/b`, to include the current directory. This
# is very bad.
if [[ -z "${LD_LIBRARY_PATH// }" ]]; then
    export LD_LIBRARY_PATH=~/.local/lib64:~/.local/lib
else
    export LD_LIBRARY_PATH=~/.local/lib64:~/.local/lib:$LD_LIBRARY_PATH
fi

