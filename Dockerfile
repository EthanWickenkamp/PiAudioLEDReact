# Base Image: Raspberry Pi OS (Debian-based)
FROM balenalib/raspberrypi3-debian:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    bluealsa \
    bluez-alsa-utils \
    alsa-utils \
    pulseaudio \
    pulseaudio-utils \
    bluetooth \
    bluez \
    dbus \
    python3 \
    python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Copy config files
COPY config/bluealsa.conf /etc/bluealsa.conf
COPY config/alsa.conf /etc/asound.conf

# Copy scripts
COPY src /app
WORKDIR /app

# Make scripts executable
RUN chmod +x /app/bluetooth_receiver.sh

# Start Bluetooth service and receiver script
CMD ["/bin/bash", "/app/bluetooth_receiver.sh"]
