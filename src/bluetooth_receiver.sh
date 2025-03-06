#!/bin/bash

# Start DBus
/etc/init.d/dbus start

# Start Bluetooth service
service bluetooth start

# Make device discoverable and pairable
bluetoothctl power on
bluetoothctl agent on
bluetoothctl discoverable on
bluetoothctl pairable on

# Start BlueALSA (If using BlueALSA)
bluealsa &

# Ensure ALSA is using the correct device
amixer cset numid=3 1

# Start Pulseaudio (if used)
pulseaudio --start --verbose

echo "Bluetooth audio receiver ready..."
tail -f /dev/null  # Keep the container running
