#!/bin/bash
set -e

echo "📲 Starting bluetoothd as root..."
bluetoothd --experimental &

sleep 2

echo "👤 Switching to 'audiouser' and starting PulseAudio..."
su - audiouser -c "export PULSE_SERVER=''; pulseaudio --start --disallow-exit --exit-idle-time=-1 --daemonize=no &"

sleep 3

echo "🔗 Setting up bluetoothctl..."
su - audiouser -c "bluetoothctl << EOF
power on
agent NoInputNoOutput
default-agent
discoverable on
pairable on
EOF
"

echo "✅ Bluetooth audio sink is ready!"
sleep infinity
