#!/bin/bash

echo "Starting Bluetooth & PulseAudio setup..."

# Start DBus and Bluetooth
service dbus start
service bluetooth start

# Wait for Bluetooth adapter to be available
echo "Waiting for Bluetooth adapter..."
until bluetoothctl show | grep "Controller"; do
    sleep 2
done

echo "Bluetooth adapter found!"

# Set up Bluetooth
bluetoothctl power on
bluetoothctl agent on
bluetoothctl discoverable on
bluetoothctl pairable on
bluetoothctl default-agent

# Start PulseAudio (if it's not already running)
pulseaudio --start --verbose

# Load Bluetooth Audio Module
pactl load-module module-bluetooth-policy
pactl load-module module-bluetooth-discover

# Set default audio sink
DEFAULT_SINK=$(pactl list short sinks | awk '{print $2}' | head -n 1)
if [[ -n "$DEFAULT_SINK" ]]; then
    pactl set-default-sink "$DEFAULT_SINK"
else
    echo "No valid audio sink found!"
fi

# Keep the container running
echo "Bluetooth audio receiver running..."
tail -f /dev/null
