#!/bin/bash
set -e

### 🔧 Start bluetoothd as root (it needs system D-Bus privileges)
echo "📲 Starting bluetoothd as root..."
bluetoothd --experimental --debug > /tmp/bluetoothd.log 2>&1 &
sleep 2

### 🧹 Clean up old PulseAudio files to avoid socket/auth issues
echo "🧹 Cleaning stale PulseAudio files..."
rm -rf /tmp/xdg/pulse
rm -rf /home/audiouser/.config/pulse

# Setup XDG runtime directory (used by PulseAudio for sockets)
mkdir -p /tmp/xdg
chown -R audiouser:audiouser /tmp/xdg
chmod 700 /tmp/xdg

# Setup PulseAudio config directory (optional, some configs expect it)
mkdir -p /home/audiouser/.config/pulse
chown -R audiouser:audiouser /home/audiouser/.config/pulse

### 🔊 Start PulseAudio with the correct runtime dir as audiouser
echo "👤 Starting PulseAudio as audiouser..."
su - audiouser -c "
  export XDG_RUNTIME_DIR=/tmp/xdg
  export PULSE_SERVER=unix:/tmp/xdg/pulse/native
  pulseaudio --start --disallow-exit --exit-idle-time=-1 --daemonize=yes
"

sleep 3
echo "✅ PulseAudio started, continuing to bluetooth setup..."

### 🔗 Set up bluetoothctl in non-interactive mode
echo "🔗 Configuring bluetoothctl..."
su - audiouser -c "bluetoothctl << EOF
power on
agent NoInputNoOutput
default-agent
discoverable on
pairable on
EOF
"

### 🧪 Quick debug output (safe to remove or comment out later)
echo "🔊 Testing ALSA devices:"
su - audiouser -c "aplay -l"

echo "🎛️ Testing PulseAudio modules:"
su - audiouser -c "
  export XDG_RUNTIME_DIR=/tmp/xdg
  pactl list modules short || echo 'PulseAudio not ready yet'
"

echo "🎧 Testing Bluetooth devices:"
su - audiouser -c "bluetoothctl devices"

### ✅ Done, keep container alive
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