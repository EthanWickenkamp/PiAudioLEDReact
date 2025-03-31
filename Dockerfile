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

# Patch PulseAudio system.pa config
RUN echo "load-module module-bluetooth-discover" >> /etc/pulse/system.pa && \
    echo "load-module module-bluetooth-policy" >> /etc/pulse/system.pa && \
    echo "load-module module-native-protocol-unix auth-anonymous=1" >> /etc/pulse/system.pa

# D-Bus permission fix for PulseAudio
RUN mkdir -p /usr/share/dbus-1/system.d && \
    echo '<policy user="pulse"><allow own="org.pulseaudio.Server"/></policy>' \
        > /usr/share/dbus-1/system.d/pulseaudio-system.conf

# ALSA config to route audio to PulseAudio
COPY config/alsa.conf /etc/asound.conf

# Copy app files
COPY src /app/src
WORKDIR /app

RUN chmod +x /app/src/bluetooth_receiver.sh

CMD ["/bin/bash", "/app/src/bluetooth_receiver.sh"]
