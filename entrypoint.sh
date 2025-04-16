#!/bin/bash
set -e

echo "📲 Starting bluetoothd as root..."
bluetoothd --experimental --debug > /tmp/bluetoothd.log 2>&1 &
sleep 2

echo "🧹 Cleaning stale PulseAudio files..."
rm -rf /tmp/xdg/pulse /home/audiouser/.config/pulse

mkdir -p /tmp/xdg/pulse
chown -R audiouser:audiouser /tmp/xdg
chmod 700 /tmp/xdg

echo "👤 Starting PulseAudio as audiouser (via XDG_RUNTIME_DIR)..."
su - audiouser -c "
  export XDG_RUNTIME_DIR=/tmp/xdg
  pulseaudio --start --disallow-exit --exit-idle-time=-1 --daemonize=yes
"

# ⏳ Wait briefly for PulseAudio to fully initialize and create socket
sleep 2
echo "✅ PulseAudio started at /tmp/xdg/pulse/native"

echo "🔗 Configuring bluetoothctl..."
su - audiouser -c "
  export XDG_RUNTIME_DIR=/tmp/xdg
  bluetoothctl << EOF
power on
agent NoInputNoOutput
default-agent
discoverable on
pairable on
EOF
"

echo "🔊 ALSA playback devices:"
su - audiouser -c "aplay -l"

echo "🎛️ PulseAudio modules:"
su - audiouser -c "
  export XDG_RUNTIME_DIR=/tmp/xdg
  pactl list modules short
"

echo "🎧 Bluetooth devices:"
su - audiouser -c "
  export XDG_RUNTIME_DIR=/tmp/xdg
  bluetoothctl devices
"

echo "✅ Bluetooth audio sink is ready!"
sleep infinity





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