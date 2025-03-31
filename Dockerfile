# Base Image
FROM balenalib/raspberrypi3-debian:latest

# Install packages
RUN apt-get update && apt-get install -y \
    alsa-utils \
    pulseaudio \
    pulseaudio-utils \
    pulseaudio-module-bluetooth \
    bluetooth \
    bluez \
    bluez-tools \
    dbus \
    python3 \
    python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Set D-Bus permissions for PulseAudio
RUN mkdir -p /usr/share/dbus-1/system.d && \
    echo '<policy context="default"><allow own="org.pulseaudio.Server"/></policy>' > /usr/share/dbus-1/system.d/pulseaudio-system.conf

# Copy PulseAudio configs
#COPY etc/pulse/ /etc/pulse/

# Copy ALSA config (for apps using ALSA to talk to Pulse)
COPY config/alsa.conf /etc/asound.conf

# Copy script
COPY src /app/src
WORKDIR /app
RUN chmod +x /app/src/bluetooth_receiver.sh

CMD ["/bin/bash", "/app/src/bluetooth_receiver.sh"]
