#!/bin/bash
set -e

echo "🔄 Starting Bluetooth & PulseAudio setup..."


# Remove stale PulseAudio socket
rm -f /run/pulse/native

# Start Bluetooth daemon
echo "🚀 Starting Bluetooth daemon..."
bluetoothd &
sleep 2

# Start PulseAudio in system mode
echo "🔊 Starting PulseAudio..."
pulseaudio --system --disallow-exit --no-cpu-limit --log-target=stderr &
sleep 2

# Wait for Bluetooth adapter to appear
echo "🔍 Waiting for Bluetooth adapter..."
until bluetoothctl show | grep -q "Controller"; do
    sleep 2
done
echo "✅ Bluetooth adapter ready."

# Configure Bluetooth agent
echo "⚙️ Configuring Bluetooth agent..."
bluetoothctl << EOF
power on
agent NoInputNoOutput
default-agent
discoverable on
pairable on
EOF

# Wait for user to connect
sleep 2

# Optional: Set Bluetooth sink as default if connected
echo "🎧 Checking for Bluetooth audio sink..."
DEFAULT_SINK=$(pactl list short sinks | grep bluez | awk '{print $2}' | head -n 1)
if [[ -n "$DEFAULT_SINK" ]]; then
    pactl set-default-sink "$DEFAULT_SINK"
    echo "✅ Default sink set to: $DEFAULT_SINK"
else
    echo "⚠️ No Bluetooth sink found yet — will auto-route on connect."
fi

echo "✅ Bluetooth audio receiver is running and ready!"
# Keep container alive
tail -f /dev/null
