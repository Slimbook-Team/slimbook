#!/bin/bash

force_i8042=0
force_ecwake=0
force_gpiowake=0

function enable_i8042_fix
{
    status=`cat /sys/bus/platform/devices/i8042/serio0/power/wakeup`
    
    if [ $status == "disabled" ] && [ $force_i8042 == 0 ]; then
        echo "i8042 wakeup fix is already active"
        return
    fi
    
    echo "ACTION=="add", SUBSYSTEM=="serio", DRIVERS=="atkbd", ATTR{power/wakeup}="disabled"" > /etc/udev/rules.d/99-z-slimbook-i8042.rules
}

function enable_ecwake_fix
{
    status=`grep -r acpi.ec_no_wakeup=1 /proc/cmdline /etc/default/grub /etc/default/grub.d/`
    
    if [[ -n $status ]]; then
        echo "EC wakeup fix is already active"
        return
    fi
    
    if [ -d "/etc/default/grub.d/" ]; then
        echo 'GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT acpi.ec_no_wakeup=1"' > /etc/default/grub.d/slimbook-ecwake-fix.cfg
    else
        echo 'GRUB_CMDLINE_LINUX+=" acpi.ec_no_wakeup=1"' >> /etc/default/grub
    fi
}

function enable_gpiowake_fix
{
    status=`grep -r gpiolib_acpi.ignore_wake=AMDI0030:00@6 /proc/cmdline /etc/default/grub /etc/default/grub.d/`
    
    if [[ -n $status ]]; then
        echo "GPIO wakeup fix is already active"
        return
    fi
    
    if [ -d "/etc/default/grub.d/" ]; then
        echo 'GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT gpiolib_acpi.ignore_wake=AMDI0030:00@6"' > /etc/default/grub.d/slimbook-ecwake-fix.cfg
    else
        echo 'GRUB_CMDLINE_LINUX+=" gpiolib_acpi.ignore_wake=AMDI0030:00@6"' >> /etc/default/grub
    fi
}

for opt in $@; do
    case $opt in
        "--force-i8042")
            force_i8042=1
        ;;
        
        "--force-ecwake")
            force_ecwake=1
        ;;
        
        "--force-gpiowake")
            force_gpiowake=1
        ;;
    esac
done

family=`slimbookctl info | grep family | cut -d ":" -f 2`

case $family in
    
    "evo")
        echo "Slimbook Evo"
        enable_i8042_fix
        enable_ecwake_fix
    ;;
    
    "creative")
        echo "Slimbook Creative"
        enable_i8042_fix
        enable_gpiowake_fix
    ;;

    *)
        
    ;;
esac

