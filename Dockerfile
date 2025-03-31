# Base Image: Raspberry Pi OS (Debian-based)
FROM balenalib/raspberrypi3-debian:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    alsa-utils \
    pulseaudio \
    pulseaudio-utils \
    bluetooth \
    bluez \
    dbus \
    python3 \
    python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Configure PulseAudio for anonymous system-wide access
RUN mkdir -p /var/run/pulse/.config/pulse && \
    echo "load-module module-native-protocol-unix auth-anonymous=1" >> /etc/pulse/system.pa

# Set ALSA to use PulseAudio
COPY config/alsa.conf /etc/asound.conf

# Copy Bluetooth pairing/audio script
COPY src /app/src
WORKDIR /app

# Make startup script executable
RUN chmod +x /app/src/bluetooth_receiver.sh

# Default command to run the Bluetooth receiver setup
CMD ["/bin/bash", "/app/src/bluetooth_receiver.sh"]
