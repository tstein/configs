# Fedora packages pip as pip-python. That's no fun.
if [ `whence pip-python` ]; then
    alias pip=pip-python
fi

if [ `whence virtualenvwrapper.sh` ]; then
    source =virtualenvwrapper.sh
fi

