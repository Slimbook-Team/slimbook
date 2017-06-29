#!/bin/bash
# SLIMBOOK TEAM
# RNM 23/06/2017
# We found a bug that cause the brightness at login screen and desktop 
# on Antergos reset, its only when we restart the computer at max bright
# Comment the lines that is not your OS
# By default the KDE lines are commented
BRG=$(cat /sys/class/backlight/intel_backlight/brightness)
# Antergos
if [ $BRG -ge 900 ]; then
    echo 891 > /sys/class/backlight/intel_backlight/brightness
elif [ $BRG -le 50 ]; then
    echo 93 > /sys/class/backlight/intel_backlight/brightness 
fi
# KDE
#if [ $BRG -ge 900 ]; then
#    echo 890 > /sys/class/backlight/intel_backlight/brightness
#elif [ $BRG -le 50 ]; then
#    echo 94 > /sys/class/backlight/intel_backlight/brightness 
#fi
