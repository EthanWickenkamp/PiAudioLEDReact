#!/bin/bash
set -e

echo "Starting Bluetooth & PulseAudio setup..."

# Kill old PulseAudio
if [ -e /run/pulse/pid ]; then
    echo "Killing stale PulseAudio..."
    kill -9 "$(cat /run/pulse/pid)" || true
    rm -f /run/pulse/pid
fi

# Remove stale socket (bind() fails otherwise)
rm -f /run/pulse/native

# Start PulseAudio
echo "Starting PulseAudio..."
pulseaudio --system --disallow-exit --no-cpu-limit --log-target=stderr &
sleep 2

# Bluetooth stuff
echo "Waiting for Bluetooth adapter..."
until bluetoothctl show | grep -q "Controller"; do
    sleep 2
done
echo "Bluetooth adapter found!"

bluetoothctl power on
bluetoothctl discoverable on
bluetoothctl pairable on
bluetoothctl agent NoInputNoOutput
bluetoothctl default-agent

sleep 2

DEFAULT_SINK=$(pactl list short sinks | grep bluez | awk '{print $2}' | head -n 1)
if [[ -n "$DEFAULT_SINK" ]]; then
    pactl set-default-sink "$DEFAULT_SINK"
    echo "Default sink set to: $DEFAULT_SINK"
else
    echo "⚠️ No valid Bluetooth audio sink found!"
fi

echo "Bluetooth audio receiver running..."
tail -f /dev/null
