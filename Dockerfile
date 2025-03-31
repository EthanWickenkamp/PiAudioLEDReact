# Base Image: Raspberry Pi OS
FROM balenalib/raspberrypi3-debian:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    alsa-utils \
    pulseaudio \
    pulseaudio-utils \
    pulseaudio-module-bluetooth \
    bluetooth \
    bluez \
    dbus \
    python3 \
    python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Create directories and fix PulseAudio cookie/auth issues
RUN mkdir -p /var/run/pulse/.config/pulse && \
    touch /var/run/pulse/.config/pulse/cookie && \
    mkdir -p /usr/share/dbus-1/system.d && \
    echo "load-module module-bluetooth-discover" >> /etc/pulse/system.pa && \
    echo "load-module module-bluetooth-policy" >> /etc/pulse/system.pa && \
    echo "load-module module-native-protocol-unix auth-anonymous=1" >> /etc/pulse/system.pa && \
    echo '<policy user="pulse"><allow own="org.pulseaudio.Server"/></policy>' \
      > /usr/share/dbus-1/system.d/pulseaudio-system.conf

# Set ALSA to use PulseAudio
COPY config/alsa.conf /etc/asound.conf

# Copy Bluetooth receiver script
COPY src /app/src
WORKDIR /app

# Ensure script is executable
RUN chmod +x /app/src/bluetooth_receiver.sh

# Default command
CMD ["/bin/bash", "/app/src/bluetooth_receiver.sh"]
