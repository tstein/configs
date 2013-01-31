export PYTHONPATH="~/.local/lib/python2.7/site-packages":$PYTHONPATH

# Force virtualenv to use distribute instead of setuptools. This seems more
# reliable.
export VIRTUALENV_DISTRIBUTE="true"
if [ `whence virtualenvwrapper.sh` ]; then
    source =virtualenvwrapper.sh
fi

# Fedora packages pip as pip-python.
if [ `whence pip-python` ]; then
    alias pip=pip-python
fi

