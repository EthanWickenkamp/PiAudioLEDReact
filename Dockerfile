# Base image
FROM balenalib/raspberrypi3-debian:bullseye

# Install dependencies
RUN apt-get update && apt-get install -y \
    alsa-utils \
    pulseaudio \
    pulseaudio-utils \
    pulseaudio-module-bluetooth \
    bluetooth \
    bluez \
    dbus \
    libasound2 \
    python3 \
    python3-dbus \
    python3-pip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -ms /bin/bash audiouser

# Set working dir and copy files BEFORE switching users
WORKDIR /app
COPY app/ /app/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set default command
CMD ["/bin/bash", "/entrypoint.sh"]
