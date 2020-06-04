#!/bin/bash

cut /sys/class/thermal/thermal_zone0/temp | rev | cut -c 3- | rev | sed "s/\(.\)$/.\1"°C" $0
