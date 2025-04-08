#!/bin/bash
set -e

echo "🔊 Starting PulseAudio..."
pulseaudio --start --disallow-exit --exit-idle-time=-1 --daemonize=no &

sleep 2

echo "📲 Starting bluetoothd..."
bluetoothd --experimental &

sleep 3

echo "🔗 Setting up bluetoothctl..."
bluetoothctl << EOF
power on
agent NoInputNoOutput
default-agent
discoverable on
pairable on
EOF

echo "✅ Bluetooth audio sink is ready!"
sleep infinity