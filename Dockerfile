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

# Patch PulseAudio system.pa to load modules and allow anonymous connections
RUN echo "load-module module-bluetooth-discover" >> /etc/pulse/system.pa && \
    echo "load-module module-bluetooth-policy" >> /etc/pulse/system.pa && \
    echo "load-module module-native-protocol-unix auth-anonymous=1" >> /etc/pulse/system.pa

# Set D-Bus policy to allow *any* user (including root) to register PulseAudio D-Bus service
RUN mkdir -p /usr/share/dbus-1/system.d && \
    echo '<policy context="default"><allow own="org.pulseaudio.Server"/></policy>' \
        > /usr/share/dbus-1/system.d/pulseaudio-system.conf

# ALSA config to route apps through PulseAudio
COPY config/alsa.conf /etc/asound.conf

# Copy Bluetooth receiver script and set working dir
COPY src /app/src
WORKDIR /app

# Make script executable
RUN chmod +x /app/src/bluetooth_receiver.sh

# Start the script on container start
CMD ["/bin/bash", "/app/src/bluetooth_receiver.sh"]
