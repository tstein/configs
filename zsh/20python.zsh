if [ `whence virtualenvwrapper.sh` ]; then
    source =virtualenvwrapper.sh
fi

# Fedora packages pip as pip-python. However, virtualenv will install it as
# `pip`. Aliasing pip to pip-python will mask the venv's pip.
if whence pip-python >/dev/null; then
    if [ ! -e ~/.local/bin/pip ]; then
        ln -s =pip-python ~/.local/bin/pip
    fi
fi

