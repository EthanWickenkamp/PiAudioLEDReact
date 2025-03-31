# Base Image
FROM balenalib/raspberrypi3-debian:bullseye

# Install packages
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


WORKDIR /app
COPY app/ /app/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
