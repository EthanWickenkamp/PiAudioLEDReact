#!/bin/bash

set -e

echo "📲 Starting bluetoothd as root..."
bluetoothd --experimental --debug > /tmp/bluetoothd.log 2>&1 &
sleep 2

echo "🛠 Setting up secure directories with correct permissions..."
# Create a completely fresh directory structure
mkdir -p /tmp/pulse
chmod 700 /tmp/pulse
chown audiouser:audiouser /tmp/pulse

# Point to this directory instead
export PULSE_RUNTIME_PATH="/tmp/pulse"

echo "🔗 Configuring bluetoothctl as audiouser..."
su - audiouser -c "
  export PULSE_SERVER=unix:/run/user/1000/pulse/native
  export XDG_RUNTIME_DIR=/run/user/1000
  export PULSE_RUNTIME_PATH=/tmp/pulse
  
  bluetoothctl << EOF
power on
agent NoInputNoOutput
default-agent
discoverable on
pairable on
EOF
"

echo "🔊 ALSA playback devices:"
su - audiouser -c "
  export PULSE_SERVER=unix:/run/user/1000/pulse/native
  export XDG_RUNTIME_DIR=/run/user/1000
  export PULSE_RUNTIME_PATH=/tmp/pulse
  aplay -l
"

echo "🎛️ PulseAudio modules:"
su - audiouser -c "
  export PULSE_SERVER=unix:/run/user/1000/pulse/native
  export XDG_RUNTIME_DIR=/run/user/1000
  export PULSE_RUNTIME_PATH=/tmp/pulse
  pactl list modules short
"

echo "🎧 Bluetooth devices:"
su - audiouser -c "
  export PULSE_SERVER=unix:/run/user/1000/pulse/native
  export XDG_RUNTIME_DIR=/run/user/1000
  export PULSE_RUNTIME_PATH=/tmp/pulse
  bluetoothctl devices
"

echo "📜 Running app..."
su - audiouser -c "
  export PULSE_SERVER=unix:/run/user/1000/pulse/native
  export XDG_RUNTIME_DIR=/run/user/1000
  export PULSE_RUNTIME_PATH=/tmp/pulse
  python3 /app/audio.py
"


echo "✅ Bluetooth audio sink is ready!"
sleep infinity











# set -e

# echo "📲 Starting bluetoothd as root..."
# bluetoothd --experimental --debug > /tmp/bluetoothd.log 2>&1 &
# sleep 2

# echo "🛠 Ensuring /home/audiouser/.config has correct permissions..."
# # Only create and fix up the parent config directory
# mkdir -p /home/audiouser/.config
# # If .config/pulse is not mounted, allow it to be created
# if [ ! -f /home/audiouser/.config/pulse/cookie ]; then
#   mkdir -p /home/audiouser/.config/pulse
#   chown -R audiouser:audiouser /home/audiouser/.config/pulse
# fi
# # Always fix ownership of the .config parent dir (just in case)
# #chown audiouser:audiouser /home/audiouser/.config

# echo "🔗 Configuring bluetoothctl as audiouser..."
# su - audiouser -c "
#   export PULSE_SERVER=unix:/run/user/1000/pulse/native
#   bluetoothctl << EOF
# power on
# agent NoInputNoOutput
# default-agent
# discoverable on
# pairable on
# EOF
# "

# echo "🔊 ALSA playback devices:"
# su - audiouser -c "aplay -l"

# echo "🎛️ PulseAudio modules:"
# su - audiouser -c "
#   export PULSE_SERVER=unix:/run/user/1000/pulse/native
#   pactl list modules short
# "

# echo "🎧 Bluetooth devices:"
# su - audiouser -c "
#   export PULSE_SERVER=unix:/run/user/1000/pulse/native
#   bluetoothctl devices
# "

# echo "✅ Bluetooth audio sink is ready!"
# sleep infinity















# set -e

# echo "📲 Starting bluetoothd as root..."
# bluetoothd --experimental --debug > /tmp/bluetoothd.log 2>&1 &
# sleep 2

# echo "🧹 Cleaning stale PulseAudio files..."
# rm -rf /tmp/xdg/pulse /home/audiouser/.config/pulse

# mkdir -p /tmp/xdg/pulse
# chown -R audiouser:audiouser /tmp/xdg
# chmod 700 /tmp/xdg

# echo "👤 Starting PulseAudio as audiouser (via XDG_RUNTIME_DIR)..."
# su - audiouser -c "
#   export XDG_RUNTIME_DIR=/tmp/xdg
#   pulseaudio --start --disallow-exit --exit-idle-time=-1 --daemonize=yes
# "

# # ⏳ Wait briefly for PulseAudio to fully initialize and create socket
# sleep 2
# echo "✅ PulseAudio started at /tmp/xdg/pulse/native"

# echo "🔗 Configuring bluetoothctl..."
# su - audiouser -c "
#   export XDG_RUNTIME_DIR=/tmp/xdg
#   bluetoothctl << EOF
# power on
# agent NoInputNoOutput
# default-agent
# discoverable on
# pairable on
# EOF
# "

# echo "🔊 ALSA playback devices:"
# su - audiouser -c "aplay -l"

# echo "🎛️ PulseAudio modules:"
# su - audiouser -c "
#   export XDG_RUNTIME_DIR=/tmp/xdg
#   pactl list modules short
# "

# echo "🎧 Bluetooth devices:"
# su - audiouser -c "
#   export XDG_RUNTIME_DIR=/tmp/xdg
#   bluetoothctl devices
# "

# echo "✅ Bluetooth audio sink is ready!"
# sleep infinity





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