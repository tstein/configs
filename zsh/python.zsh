# Fedora packages pip as pip-python. Using the external /bin/which ensures we
# get a real path and not a printout of an alias, even in nested zshes.
if [ `whence pip-python` ]; then
    _PIP_PATH=`/bin/which pip-python`
else
    _PIP_PATH=`/bin/which pip`
fi

# Force virtualenv to use distribute instead of setuptools. This seems more
# reliable.
export VIRTUALENV_DISTRIBUTE="true"
if [ `whence virtualenvwrapper.sh` ]; then
    source =virtualenvwrapper.sh
fi

# Since 1.1, pip knows what a virtualenv is. Remove this once that's widespread.
#update_pip_alias() {
#    if [ "$VIRTUAL_ENV" ]; then
#        alias pip="$_PIP_PATH -E \"$VIRTUAL_ENV\""
#    else
#        alias pip="$_PIP_PATH"
#    fi
#}
#precmd_functions=($precmd_functions update_pip_alias)

