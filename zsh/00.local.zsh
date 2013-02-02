# Set up the ~/.local hierarchy.

if [ ! -d ~/.local ]; then
    mkdir ~/.local
fi
SUBDIRS=(bin lib share tmp)
for DIR in $SUBDIRS; do
    if [ ! -d ~/.local/$DIR ]; then
        mkdir ~/.local/$DIR
    fi
done

