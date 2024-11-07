#!/bin/bash

case "$1" in
    "up")
        brightnessctl set +5%  # Increase brightness by 5%
        ;;
    "down")
        brightnessctl set 5%-  # Decrease brightness by 5%
        ;;
    *)
        brightness=$(brightnessctl get) 
        max_brightness=$(brightnessctl max)
        brightness_percent=$(( brightness * 100 / max_brightness ))
        echo "{\"text\": \"Brightness: ${brightness_percent}%\", \"tooltip\": \"Current brightness level\"}"
        ;;
esac

