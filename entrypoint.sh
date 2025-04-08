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

# 🔁 Auto-loopback Bluetooth → analog jack
echo "🎧 Waiting for Bluetooth A2DP source and analog sink..."

(
  looped=0
  while [ $looped -eq 0 ]; do
    su - audiouser -c '
      export XDG_RUNTIME_DIR=/tmp/xdg

      source_line=$(pactl list short sources | grep bluez_source || true)
      sink_line=$(pactl list short sinks | grep bcm2835 || true)

      if [[ -n "$source_line" && -n "$sink_line" ]]; then
        source_name=$(echo "$source_line" | awk "{print \$2}")
        sink_name=$(echo "$sink_line" | awk "{print \$2}")

        echo "🔊 Bluetooth source: $source_name"
        echo "🎚️  Analog sink: $sink_name"

        echo "🔁 Creating loopback from $source_name → $sink_name"
        pactl load-module module-loopback source=$source_name sink=$sink_name latency_msec=50

        echo "🔈 Setting volume to 80% on sink: $sink_name"
        pactl set-sink-volume "$sink_name" 80%

        looped=1
      else
        echo "⏳ Waiting for source/sink... Retrying in 5s"
      fi
    '
    sleep 5
  done
) &

echo "✅ Bluetooth audio sink is ready!"
sleep infinity
