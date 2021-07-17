# Get the lay of the land and save it in an associative array.

typeset -A __prop
function set_prop() { __prop[$1]=$2 }
function get_prop() { print ${__prop[$1]} }

# Text encoding?
local ENCODING=`print -n $LANG | grep -oe '[^.]*$'`
# Mangle this a bit to deal with platform differences.
ENCODING=`print -n $ENCODING | tr '[a-z]' '[A-Z]' | tr -d -`
if [ ! $ENCODING ]; then
    ENCODING='UNKNOWN'
fi
set_prop encoding $ENCODING
if [[ `get_prop encoding` == 'UTF8' ]]; then
    set_prop unicode yes
fi

# Operating system?
case `uname -s` in
  'Linux')
    set_prop OS Linux
    ;;
  'Darwin')
    set_prop OS Ossix
    ;;
esac

# Installed programs?
for i in acpi keychain git nvim timeout; do
  if [ `whence $i` ]; then
    set_prop "have_$i" yes
  fi
done

# Laptop? (i.e., Can we access laptop-specific power info?)
case `get_prop OS` in
  'Linux')
    if [ `get_prop have_acpi` ]; then
      if [ "`acpi -b 2>/dev/null`" ]; then
        set_prop have_battery yes
      fi
    fi
    ;;
  'Ossix')
    if [ "`system_profiler SPHardwareDataType | grep 'MacBook'`" ]; then
      set_prop have_battery yes
    fi
    ;;
esac
