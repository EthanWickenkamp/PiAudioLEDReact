#!/bin/bash
set -e

echo "📲 Starting bluetoothd as root..."
bluetoothd --experimental &

sleep 2

echo "🧹 Cleaning stale PulseAudio files..."
rm -rf /tmp/xdg/pulse
rm -rf /home/audiouser/.config/pulse

mkdir -p /tmp/xdg
chown -R audiouser:audiouser /tmp/xdg
chmod 700 /tmp/xdg

mkdir -p /home/audiouser/.config/pulse
chown -R audiouser:audiouser /home/audiouser/.config/pulse

# 3. Start PulseAudio as audiouser
echo "👤 Starting PulseAudio as audiouser..."
su - audiouser -c "
  export XDG_RUNTIME_DIR=/tmp/xdg
  export PULSE_SERVER=''
  pulseaudio --start --disallow-exit --exit-idle-time=-1 --daemonize=yes
"

sleep 3
echo "✅ PulseAudio started, continuing to bluetooth setup..."

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
