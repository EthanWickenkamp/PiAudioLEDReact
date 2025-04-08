#!/bin/bash
set -e

echo "📲 Starting bluetoothd as root..."
bluetoothd --experimental --debug > /tmp/bluetoothd.log 2>&1 &
sleep 2

echo "🧹 Cleaning stale PulseAudio files..."
rm -rf /tmp/xdg/pulse
rm -rf /home/audiouser/.config/pulse

mkdir -p /tmp/xdg
chown -R audiouser:audiouser /tmp/xdg
chmod 700 /tmp/xdg

mkdir -p /home/audiouser/.config/pulse
chown -R audiouser:audiouser /home/audiouser/.config/pulse

echo "👤 Starting PulseAudio as audiouser..."
su - audiouser -c "
  export XDG_RUNTIME_DIR=/tmp/xdg
  export PULSE_SERVER=unix:/tmp/xdg/pulse/native
  mkdir -p /tmp/xdg/pulse
  chmod 700 /tmp/xdg/pulse
  pulseaudio --start --disallow-exit --exit-idle-time=-1 --daemonize=yes
"

# Add debug info to see if socket was created
echo "🔍 Checking PulseAudio socket..."
ls -la /tmp/xdg/pulse/
sleep 3

echo "🔌 Loading Bluetooth modules for PulseAudio..."
su - audiouser -c "
  export XDG_RUNTIME_DIR=/tmp/xdg
  pactl load-module module-bluetooth-discover
  pactl load-module module-bluetooth-policy
  pactl load-module module-switch-on-connect
"


echo "🔗 Configuring bluetoothctl..."
su - audiouser -c "bluetoothctl << EOF
power on
agent NoInputNoOutput
default-agent
discoverable on
pairable on
EOF
"

# After starting PulseAudio
echo "🔊 Testing ALSA devices:"
su - audiouser -c "aplay -l"

echo "🎛️ Testing PulseAudio modules:"
su - audiouser -c "pactl list modules short"

echo "🎧 Testing Bluetooth devices:"
su - audiouser -c "bluetoothctl devices"

# # 🔁 Start auto-trust loop
# echo "🔁 Starting auto-trust loop..."
# (
#   while true; do
#     su - audiouser -c '
#       bluetoothctl paired-devices | awk "{print \$2}" | while read -r mac; do
#         bluetoothctl trust "$mac" > /dev/null 2>&1
#       done
#     '
#     sleep 5
#   done
# ) &


echo "✅ Bluetooth audio sink is ready! "
sleep infinity
