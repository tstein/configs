function survey() {
    # extract text [key]
    #   Return everything after the first : in text, chomped. If key is given,
    #   grep for key first.
    function extract() {
        local line=$1
        if [[ $# == 2 ]]; then
            local key=$2
            line=`print $line | grep $key`
        fi
        print $line | cut -d : -f 2- | chomp
    }

    function linux_cpus() {
        local cpus
        if grep -q 'Hardware' /proc/cpuinfo; then
            # Qualcomm phone/tablet SoC
            # cpuinfo will sometimes have both 'Hardware' and 'model name's, so
            # check this first.
            local hardware_line=`grep '^Hardware' /proc/cpuinfo`
            local hardware=`extract $hardware_line`
            cpus=`print $hardware | sed 's/ Technologies, Inc//'`
        elif grep -q 'model name' /proc/cpuinfo; then
            # Intel, AMD, Broadcom
            local cpu_lines=`grep 'model name' /proc/cpuinfo`
            local cpu_line=`print $cpu_lines | head -n 1`
            local cpu_count=`print $cpu_lines | wc -l`
            # Clean up some Intel stuff.
            local cpu=`extract $cpu_line | sed 's/(R)//g' | sed 's/(TM)//g'`
            cpu=`print $cpu | sed 's/^.* Gen //'`
            cpu=`print $cpu | sed 's/\s\?CPU\s\?/ /'`
            # Clean up AMD APU info.
            cpu=`print $cpu | sed 's/ [A-Za-z0-9]*-Core Processor//'`
            cpu=`print $cpu | sed 's/ with .* Graphics//g'`
            # Clean up spacing.
            cpu=`print $cpu | sed 's/\s\+/ /g'`

            cpus="${cpu_count}x $cpu"
        elif grep -q 'system type' /proc/cpuinfo; then
            # Qualcomm netdev SoC
            system_line=`grep 'system type' /proc/cpuinfo`
            system=`extract $system_line | sed -r 's/(ver|rev)\s+\d+//g'`
            cpus=$system
        else
            cpus='unknown'
        fi

        if print $cpus | grep -q ' @ .*Hz'; then
            cpus=`print $cpus | sed "s/ @.*//"`
        fi

        # If we frequency info at all, use it. If we have heterogenous CPUs,
        # capture that, too.
        if [ -e /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq ]; then
          local freqs=`sort -rn /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_max_freq`
          local uniq_freqs=`print $freqs | uniq`

          function fmt_freq() {
              printf '%.2f' $(($1 / 1000000.0))
          }

          if [ $(print $uniq_freqs | wc -l) -gt 1 ]; then
              for freq in `print $uniq_freqs`; do
                  local freq_count=`print $freqs | grep $freq | wc -l`
                  cpus="$cpus, ${freq_count} @ `fmt_freq $freq` GHz"
              done
          else
              # uniq_freqs is the sole frequency
              cpus="$cpus @ `fmt_freq $uniq_freqs` GHz"
          fi
        fi

        print $cpus
    }


    local os release model cpus mem swap

    local os=`uname -s`
    case $os in
        'Linux')
            if [[ `uname -o` == 'Android' ]]; then
                os='Android'
            else
                os=`uname -sr`
            fi
            ;;
        'Darwin')
            os='macOS'
            ;;
    esac

    case $os in
        Linux*)
            if [[ -e /etc/os-release ]]; then
                source /etc/os-release
                release=$PRETTY_NAME
            else
                release='unknown'
            fi


            # Raspberry Pi
            local model_file="/proc/device-tree/model"
            if [ -e $model_file ]; then
                model=`cat $model_file | tr -d '\0'`
            elif `grep -q 'model' /proc/cpuinfo`; then
                machine_line=`grep 'machine' /proc/cpuinfo`
                model=`extract $machine_line`
            fi

            cpus=`linux_cpus`

            local meminfo=`cat /proc/meminfo`
            local mem_kb=`extract $meminfo 'MemTotal' | sed 's/ kB//'`
            mem="$(($mem_kb / 1024)) MB"

            local swap_kb=`extract $meminfo 'SwapTotal' | sed 's/ kB//'`
            if [[ $swap_kb != '0' ]]; then
                swap="$(($swap_kb / 1024)) MB"
            fi
            ;;

        'Android')
            release=`getprop ro.build.version.release`

            model=`getprop ro.product.model`

            cpus=`linux_cpus`

            local meminfo=`cat /proc/meminfo`
            local mem_kb=`extract $meminfo 'MemTotal' | sed 's/ kB//'`
            mem="$(($mem_kb / 1024)) MB"

            local swap_kb=`extract $meminfo 'SwapTotal' | sed 's/ kB//'`
            if [[ $swap_kb != '0' ]]; then
                swap="$(($swap_kb / 1024)) MB"
            fi
            ;;

        'macOS')
            release=`sw_vers -productVersion`
            local sp_hardware=`system_profiler SPHardwareDataType`

            model=`extract $sp_hardware 'Model Identifier'`

            local cpu=`extract $sp_hardware 'Processor Name'`
            local cpu_speed=`extract $sp_hardware 'Processor Speed'`
            local cpu_count=`extract $sp_hardware 'Total Number of Cores'`
            cpus="${cpu_count}x $cpu @ $cpu_speed"

            mem=`extract $sp_hardware 'Memory'`
            ;;
    esac

    print "OS:          $os"
    print "Release:     $release"
    if [[ $model != "" ]]; then
        print "Model:       $model"
    fi
    print "CPUs:        $cpus"
    print "RAM:         $mem"
    if [[ $swap != "" ]]; then
        print "Swap:        $swap"
    fi

}
