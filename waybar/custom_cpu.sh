#!/bin/bash

# Get CPU usage
cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}' | awk '{printf "%.1f", $1}')

# Get memory usage in percentage
memory_usage_percent=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100}')

# Get memory usage in GB
memory_usage_gb=$(free | grep Mem | awk '{printf "%.1f", $3/1024/1024}')

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

# Get network RX and TX
network_interface=$(ip route | grep '^default' | awk '{print $5}')
rx_bytes_initial=$(cat /sys/class/net/$network_interface/statistics/rx_bytes)
tx_bytes_initial=$(cat /sys/class/net/$network_interface/statistics/tx_bytes)
sleep 1
rx_bytes_final=$(cat /sys/class/net/$network_interface/statistics/rx_bytes)
tx_bytes_final=$(cat /sys/class/net/$network_interface/statistics/tx_bytes)
rx_rate=$(awk "BEGIN {printf \"%.2f\", ($rx_bytes_final - $rx_bytes_initial) / 1024 / 1024}")
tx_rate=$(awk "BEGIN {printf \"%.2f\", ($tx_bytes_final - $tx_bytes_initial) / 1024 / 1024}")

# Create JSON output
printf '{"text": "%s%% |%sGB |%s°C |%sMB/s |%sMB/s ", "tooltip": "CPU Usage: %s%%\\nRAM Usage: %s%% (%sGB)\\nTemperature: %s°C\\nRX: %sMB/s\\nTX: %sMB/s"}' \
    "$(printf "%04.1f" "$cpu_usage")" "$memory_usage_gb" "$temperature" "$rx_rate" "$tx_rate" \
    "$(printf "%04.1f" "$cpu_usage")" "$memory_usage_percent" "$memory_usage_gb" "$temperature" "$rx_rate" "$tx_rate"