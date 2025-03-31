#!/bin/bash
set -e

echo "🧹 Cleaning up stale PulseAudio runtime state..."
rm -rf /run/pulse /var/run/pulse /var/lib/pulse ~/.config/pulse ~/.pulse


if ! pgrep -x dbus-daemon > /dev/null; then
  echo "🔧 Starting D-Bus..."
  dbus-daemon --system --nofork &
else
  echo "⚠️ D-Bus already running, skipping manual start"
fi



echo "📲 Starting bluetoothd..."
bluetoothd --experimental &
echo "🔊 Starting PulseAudio..."
pulseaudio --system --disallow-exit --no-cpu-limit &

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