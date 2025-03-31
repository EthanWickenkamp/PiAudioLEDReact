#!/bin/bash
set -e

echo "Starting Bluetooth & PulseAudio setup..."

# Start PulseAudio in system mode if not already running
if ! pactl info > /dev/null 2>&1; then
    echo "Starting PulseAudio..."
    pulseaudio --system --disallow-exit --no-cpu-limit --log-target=stderr &
    sleep 2
fi

# Wait for Bluetooth adapter
echo "Waiting for Bluetooth adapter..."
until bluetoothctl show | grep -q "Controller"; do
    sleep 2
done
echo "Bluetooth adapter found!"

# Bluetooth pairing setup
bluetoothctl power on
bluetoothctl discoverable on
bluetoothctl pairable on
bluetoothctl agent NoInputNoOutput
bluetoothctl default-agent

# Let Bluetooth stack settle
sleep 2

# Set default Bluetooth sink (if connected)
DEFAULT_SINK=$(pactl list short sinks | grep bluez | awk '{print $2}' | head -n 1)
if [[ -n "$DEFAULT_SINK" ]]; then
    pactl set-default-sink "$DEFAULT_SINK"
    echo "Default sink set to: $DEFAULT_SINK"
else
    echo "⚠️ No valid Bluetooth audio sink found!"
fi

echo "Bluetooth audio receiver running..."
tail -f /dev/null
