# ty needs this to see user-installed packages.
export PYTHONPATH=$(python -c 'import sys; print(":".join(p for p in sys.path if ".local" in p))')
