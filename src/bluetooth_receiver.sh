#!/bin/bash

echo "Starting Bluetooth & PulseAudio setup..."

# Start PulseAudio in system mode (more container-friendly)
pulseaudio --system --disallow-exit --no-cpu-limit --log-target=stderr &
# Give PulseAudio a second to spin up
sleep 2



# Wait for Bluetooth adapter to be available
echo "Waiting for Bluetooth adapter..."
until bluetoothctl show | grep -q "Controller"; do
    sleep 2
done

echo "Bluetooth adapter found!"


# Optional: Set up pairing environment (skip if handled by host)
bluetoothctl power on
bluetoothctl agent on
bluetoothctl discoverable on
bluetoothctl pairable on
bluetoothctl default-agent

# Load Bluetooth Audio Module
pactl load-module module-bluetooth-policy
pactl load-module module-bluetooth-discover

# Set default audio sink to the first Bluetooth sink found
DEFAULT_SINK=$(pactl list short sinks | grep bluez | awk '{print $2}' | head -n 1)
if [[ -n "$DEFAULT_SINK" ]]; then
    pactl set-default-sink "$DEFAULT_SINK"
    echo "Default sink set to: $DEFAULT_SINK"
else
    echo "⚠️ No valid Bluetooth audio sink found!"
fi

# Keep the container running
echo "Bluetooth audio receiver running..."
tail -f /dev/null
