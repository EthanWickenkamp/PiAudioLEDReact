#!/bin/bash

echo "Starting Bluetooth services..."
service bluetooth start
hciconfig hci0 up
bluetoothctl <<EOF
power on
agent on
discoverable on
pairable on
EOF

echo "Forcing audio output to 3.5mm jack..."
amixer cset numid=3 1  # Forces audio to analog jack

echo "Starting Bluetooth audio sink..."
bluealsa &
aplay -D plughw:0,0 /dev/null
