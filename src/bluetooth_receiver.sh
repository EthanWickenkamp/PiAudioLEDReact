#!/bin/bash
set -e

echo "Starting Bluetooth & PulseAudio setup..."

# Kill stale PulseAudio
if [ -e /run/pulse/pid ]; then
    echo "Killing stale PulseAudio..."
    kill -9 "$(cat /run/pulse/pid)" || true
    rm -f /run/pulse/pid
fi

# Remove stale socket
rm -f /run/pulse/native

# Start PulseAudio
echo "Starting PulseAudio..."
pulseaudio --system --disallow-exit --no-cpu-limit --log-target=stderr &
sleep 2

# Wait for Bluetooth adapter
echo "Waiting for Bluetooth adapter..."
until bluetoothctl show | grep -q "Controller"; do
    sleep 2
done
echo "Bluetooth adapter found!"

# Setup Bluetooth agent
bluetoothctl power on
bluetoothctl discoverable on
bluetoothctl pairable on
bluetoothctl agent NoInputNoOutput
bluetoothctl default-agent
sleep 2

# Set default audio sink to Bluetooth (if available)
echo "Checking for Bluetooth audio sink..."
DEFAULT_SINK=$(pactl list short sinks | grep bluez | awk '{print $2}' | head -n 1)
if [[ -n "$DEFAULT_SINK" ]]; then
    pactl set-default-sink "$DEFAULT_SINK"
    echo "✅ Default sink set to: $DEFAULT_SINK"
else
    echo "⚠️ No valid Bluetooth audio sink found!"
fi

echo "🎵 Bluetooth audio receiver running..."
tail -f /dev/null
