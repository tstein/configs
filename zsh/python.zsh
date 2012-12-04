# Fedora packages pip as pip-python. Using the external /bin/which ensures we
# get a real path and not a printout of an alias, even in nested zshes.
if [ `whence pip-python` ]; then
    _PIP_PATH=`/bin/which pip-python`
else
    _PIP_PATH=`/bin/which pip`
fi

if [ `whence virtualenvwrapper.sh` ]; then
    source =virtualenvwrapper.sh
fi

# At time of writing, pip will not detect an active venv and install to it.
update_pip_alias() {
    if [ "$VIRTUAL_ENV" ]; then
        alias pip="$_PIP_PATH -E \"$VIRTUAL_ENV\""
    else
        alias pip="$_PIP_PATH"
    fi
}
precmd_functions=($precmd_functions update_pip_alias)

