# Force virtualenv to use distribute instead of setuptools. This seems more
# reliable.
export VIRTUALENV_DISTRIBUTE="true"
if [ `whence virtualenvwrapper.sh` ]; then
    source =virtualenvwrapper.sh
fi

# Fedora packages pip as pip-python. However, virtualenv will install it as
# `pip`. Aliasing pip to pip-python will mask the venv's pip.
if [ =pip-python ]; then
    if [ ! -e ~/.local/bin/pip ]; then
        ln -s =pip-python ~/.local/bin/pip
    fi
fi

