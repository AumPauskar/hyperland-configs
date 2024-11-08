#!/bin/bash

# Get CPU usage
cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}' | awk '{printf "%.1f", $1}')

# Get memory usage
memory_usage=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100}')

# Get CPU temperature (with fallback)
if [ -f "/sys/class/thermal/thermal_zone0/temp" ]; then
    temperature=$(cat /sys/class/thermal/thermal_zone0/temp | awk '{printf "%.1f", $1/1000}')
else
    temperature=$(sensors 2>/dev/null | grep 'Package id 0:' | awk '{print $4}' | tr -d '+°C' || echo "N/A")
fi

# Determine temperature icon based on simple numeric comparison
temp_icon=""
if [ "$temperature" != "N/A" ]; then
    if [ $(printf "%.0f" "$temperature") -lt 50 ]; then
        temp_icon=""
    elif [ $(printf "%.0f" "$temperature") -lt 75 ]; then
        temp_icon=""
    else
        temp_icon=""
    fi
fi

# Create JSON output
printf '{"text": "CPU: %s%% | RAM: %s%% | %s°C %s", "tooltip": "CPU Usage: %s%%\\nRAM Usage: %s%%\\nTemperature: %s°C"}' \
    "$cpu_usage" "$memory_usage" "$temperature" "$temp_icon" \
    "$cpu_usage" "$memory_usage" "$temperature"