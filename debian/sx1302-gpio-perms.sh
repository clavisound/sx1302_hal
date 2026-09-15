#!/bin/sh
# Ensure the SX1302 reset/power GPIO lines are readable and writable by
# members of the 'dialout' group. Runs at boot (and on package install)
# via sx1302-hal-gpio-perms.service.
#
# Bobcat 300 GPIO mapping (global sysfs numbers):
#   122 -> SX1302_EXTRA
#   125 -> SX1302_POWER_EN
#   149 -> SX1302_RESET
#
# The kernel creates /sys/class/gpio/gpioN/{direction,value} as
# root:root 0644 on export. We change them to root:dialout 0660 so that
# dialout-group users can drive them without root.

set -e

GPIO_LIST="122 125 149"

for n in $GPIO_LIST; do
    if [ ! -d "/sys/class/gpio/gpio$n" ]; then
        echo "$n" > /sys/class/gpio/export
        sleep 0.1
    fi

    for f in direction value; do
        target="/sys/class/gpio/gpio$n/$f"
        if [ -e "$target" ]; then
            chown root:dialout "$target" 2>/dev/null || true
            chmod 0660          "$target" 2>/dev/null || true
        fi
    done
done

exit 0
