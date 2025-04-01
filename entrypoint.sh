#!/bin/bash
set -e

# echo "🧹 Cleaning up stale PulseAudio runtime state..."
# rm -rf /run/user/1000/pulse ~/.config/pulse ~/.pulse

echo "📲 Starting bluetoothd..."
bluetoothd --experimental &

echo "🔊 Starting PulseAudio..."
pulseaudio --start --disallow-exit --exit-idle-time=-1

sleep 3

bluetoothctl << EOF
power on
agent NoInputNoOutput
default-agent
discoverable on
pairable on
EOF

echo "📜 Running app..."
python3 /app/main.py &

echo "✅ Bluetooth audio sink is ready! sleep infinity now"
sleep infinity
