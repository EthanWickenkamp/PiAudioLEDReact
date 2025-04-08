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
  export PULSE_SERVER=''
  pulseaudio --start --disallow-exit --exit-idle-time=-1 --daemonize=yes
"

sleep 3
echo "✅ PulseAudio started, continuing to bluetooth setup..."

echo "🔗 Configuring bluetoothctl..."
su - audiouser -c "bluetoothctl << EOF
power on
agent NoInputNoOutput
default-agent
discoverable on
pairable on
EOF
"

# 🔁 Start auto-trust loop
echo "🔁 Starting auto-trust loop..."
(
  while true; do
    su - audiouser -c '
      bluetoothctl paired-devices | awk "{print \$2}" | while read -r mac; do
        bluetoothctl trust "$mac" > /dev/null 2>&1
      done
    '
    sleep 5
  done
) &

# 🔁 Loopback Bluetooth audio to 3.5mm jack if available
echo "🔁 Waiting for Bluetooth source to become available..."

(
  while true; do
    su - audiouser -c '
      export XDG_RUNTIME_DIR=/tmp/xdg

      source_name=$(pactl list short sources | grep bluez_source | awk "{print \$2}")
      sink_name=$(pactl list short sinks | grep bcm2835 | awk "{print \$2}")

      if [ -n "$source_name" ] && [ -n "$sink_name" ]; then
        echo "🔊 Looping Bluetooth source ($source_name) to sink ($sink_name)"
        pactl load-module module-loopback source=$source_name sink=$sink_name latency_msec=50
        exit 0
      fi
    '
    sleep 5
  done
) &

echo "✅ Bluetooth audio sink is ready!"
sleep infinity
