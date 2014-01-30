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

export LD_LIBRARY_PATH=~/.local/lib64:~/.local/lib:$LD_LIBRARY_PATH
